(function() {
  "use strict";
  var baseBehavior, clone, deltaValidation, errors, iter, statesBehavior, typeRegistry, validateCommonSetting, validateInitialRange, validateInitialValueWithStates, validateStateId, validateStates, validation;

  errors = require("../utilities/errors");

  baseBehavior = require("./base");

  typeRegistry = require("../utilities/type-registry");

  validation = require("../utilities/validation");

  deltaValidation = require("../deltas/validation");

  iter = require("../utilities/iteration");

  clone = require("clone");

  validateStateId = function(cdfNode, buildState) {
    var error, isPrevouslySeenState, stateDefinition, stateId, stateIdRegistry;
    stateId = cdfNode.s.stateId;
    stateDefinition = cdfNode.s.states;
    stateIdRegistry = buildState.config("stateIds");
    isPrevouslySeenState = stateIdRegistry[stateId];
    if (stateDefinition && !isPrevouslySeenState) {
      stateIdRegistry[stateId] = true;
      return [true, null];
    }
    if (!stateDefinition && isPrevouslySeenState) {
      return [true, null];
    }
    if (stateDefinition && isPrevouslySeenState) {
      error = "Found a state definition AND a colliding state ID '" + stateId + "'";
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    error = "There is no state definition in this state behavior definition AND did not encounter any previous definition for a state with id '" + stateId + "'";
    return errors.generateErrorWithTrace(error, cdfNode);
  };

  validateCommonSetting = function(cdfNode, buildState) {
    var commonState, validationFunc;
    commonState = cdfNode.s.common;
    if (!commonState) {
      return [true, null];
    }
    validationFunc = deltaValidation.validateCssSelectorDeltaPair;
    return iter.reduceWithError(commonState, validationFunc, cdfNode);
  };

  validateStates = function(cdfNode, buildState) {
    var definedStates, settings, validationFunc;
    settings = cdfNode.s;
    definedStates = settings.states;
    if (!definedStates) {
      return [true, null];
    }
    validationFunc = deltaValidation.validateCssSelectorDeltaPairs;
    return iter.reduceWithError(definedStates, validationFunc, cdfNode);
  };

  validateInitialValueWithStates = function(cdfNode, buildState) {
    var error, initialSetting, stateDefs;
    initialSetting = cdfNode.s.initial;
    stateDefs = cdfNode.s.states;
    if (initialSetting && !stateDefs) {
      error = "Cannot have an `initial` setting value in a states behavior instance that does not include the states definition";
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return [true, null];
  };

  validateInitialRange = function(cdfNode, buildState) {
    var error, initialSetting, numStates;
    initialSetting = cdfNode.s.initial;
    if (initialSetting === void 0) {
      return [true, null];
    }
    numStates = cdfNode.s.states.length;
    if (initialSetting < 0 || initialSetting >= numStates) {
      error = "Invalid 'initial' setting.  Must be in the range of [0, " + numStates + "]";
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return [true, null];
  };

  statesBehavior = function() {
    var base;
    base = baseBehavior.base();
    base.name = "states";
    base.clientScripts.push("behaviors/states");
    base.requiredSettings.push("stateId");
    base.defaultSettings = {
      wrap: false,
      advance: true
    };
    base.validSettings = {
      stateId: "string",
      common: "array:array",
      states: "array:array",
      index: "int",
      wrap: "bool",
      advance: "bool",
      initial: "int"
    };
    base.childNodes = function(cdfNode) {
      var children, commonState, cssSelector, deltaInst, state, stateSets, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      children = [];
      stateSets = cdfNode.s.states;
      if (stateSets && Array.isArray(stateSets)) {
        for (_i = 0, _len = stateSets.length; _i < _len; _i++) {
          state = stateSets[_i];
          for (_j = 0, _len1 = state.length; _j < _len1; _j++) {
            _ref = state[_j], cssSelector = _ref[0], deltaInst = _ref[1];
            children.push(deltaInst);
          }
        }
      }
      commonState = cdfNode.s.common;
      if (commonState && Array.isArray(commonState)) {
        for (_k = 0, _len2 = commonState.length; _k < _len2; _k++) {
          _ref1 = commonState[_k], cssSelector = _ref1[0], deltaInst = _ref1[1];
          children.push(deltaInst);
        }
      }
      return children;
    };
    base.behaviorSettings = function(cdfNode, buildState) {
      var cdfType, cssSelector, deltaInst, deltaSettings, deltaType, key, settings, state, _i, _len, _ref;
      cdfType = typeRegistry.getType(cdfNode);
      cdfType.clientScripts.forEach(function(script) {
        return buildState.addScriptFile(script);
      });
      settings = {};
      settings.t = cdfType.name;
      settings.s = {};
      if (cdfNode.s.common) {
        settings.s.common = (function() {
          var _i, _len, _ref, _ref1, _results;
          _ref = cdfNode.s.common;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            _ref1 = _ref[_i], cssSelector = _ref1[0], deltaInst = _ref1[1];
            deltaType = typeRegistry.getType(deltaInst);
            deltaSettings = deltaType.deltaSettings(deltaInst, buildState);
            _results.push([cssSelector, deltaSettings]);
          }
          return _results;
        })();
      }
      if (cdfNode.s.states) {
        settings.s.states = (function() {
          var _i, _len, _ref, _results;
          _ref = cdfNode.s.states;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            state = _ref[_i];
            _results.push((function() {
              var _j, _len1, _ref1, _results1;
              _results1 = [];
              for (_j = 0, _len1 = state.length; _j < _len1; _j++) {
                _ref1 = state[_j], cssSelector = _ref1[0], deltaInst = _ref1[1];
                deltaType = typeRegistry.getType(deltaInst);
                deltaSettings = deltaType.deltaSettings(deltaInst, buildState);
                _results1.push([cssSelector, deltaSettings]);
              }
              return _results1;
            })());
          }
          return _results;
        })();
      }
      _ref = ["stateId", "wrap", "advance", "index", "initial"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        if (cdfNode.s[key] !== void 0) {
          settings.s[key] = cdfNode.s[key];
        }
      }
      return settings;
    };
    base.validationFunctions.push(validateStateId);
    base.validationFunctions.push(validateCommonSetting);
    base.validationFunctions.push(validateStates);
    base.validationFunctions.push(validateInitialValueWithStates);
    base.validationFunctions.push(validateInitialRange);
    return base;
  };

  module.exports = {
    states: statesBehavior
  };

}).call(this);
