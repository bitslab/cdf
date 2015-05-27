(function() {
  "use strict";
  var baseBehavior, deltaValidators, errors, generalValidators, iter, safeValueNamePattern, typeRegistery, updateBehavior, updateBehaviorChildNodes, updateBehaviorSettings, validateCompleteDeltas, validateCssSelectorValueNamePair, validateErrorDeltas, validateLoadingDeltas, validateValuesSetting, _validateDeltaList;

  baseBehavior = require("./base");

  typeRegistery = require("../utilities/type-registery");

  generalValidators = require("../utilities/validation");

  deltaValidators = require("../deltas/validation");

  iter = require("../utilities/iteration");

  errors = require("../utilities/errors");

  safeValueNamePattern = /^[\d\w \[\]-]+$/;

  _validateDeltaList = function(settingsProperty) {
    return function(cdfNode, buildState) {
      var deltaPairs, error, isValid, _ref;
      deltaPairs = cdfNode.s[settingsProperty];
      if (!deltaPairs) {
        return [true, null];
      }
      _ref = deltaValidators.validateCssSelectorDeltaPairs(deltaPairs), isValid = _ref[0], error = _ref[1];
      if (!isValid) {
        return errors.generateErrorWithTrace(error, cdfNode);
      }
      return [true, null];
    };
  };

  validateErrorDeltas = _validateDeltaList("error");

  validateLoadingDeltas = _validateDeltaList("loading");

  validateCompleteDeltas = _validateDeltaList("complete");

  validateCssSelectorValueNamePair = function(selecterNamePair) {
    var cssSelector, error, isValid, valueName, _ref;
    if (selecterNamePair.length !== 2) {
      error = "The shape of the given [css selector, value name] pair is invalid.  Should be length two: '" + selecterNamePair + "'.";
      return [false, error];
    }
    cssSelector = selecterNamePair[0], valueName = selecterNamePair[1];
    _ref = generalValidators.isSafeCSSSelector(cssSelector), isValid = _ref[0], error = _ref[1];
    if (!isValid) {
      return [false, error];
    }
    if (!valueName.match(safeValueNamePattern)) {
      error = "'" + valueName + "' is not a safe value name, does not match regex '" + (safeValueNamePattern.toString()) + "'";
      return [false, error];
    }
    return [true, null];
  };

  validateValuesSetting = function(cdfNode, buildState) {
    var validationFunc, values;
    values = cdfNode.s.values;
    if (!values) {
      return [true, null];
    }
    validationFunc = validateCssSelectorValueNamePair;
    return iter.reduceWithError(values, validationFunc, cdfNode);
  };

  updateBehaviorChildNodes = function(cdfNode) {
    var children, cssSelector, deltaInst, settingKey, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    children = [];
    _ref = ["loading", "error", "complete"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      settingKey = _ref[_i];
      if (!cdfNode.s[settingKey] || !Array.isArray(cdfNode.s[settingKey])) {
        continue;
      }
      _ref1 = cdfNode.s[settingKey];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        _ref2 = _ref1[_j], cssSelector = _ref2[0], deltaInst = _ref2[1];
        children.push(deltaInst);
      }
    }
    return children;
  };

  updateBehaviorSettings = function(cdfNode, buildState) {
    var cdfType, cssSelector, deltaNode, deltaSettings, deltaType, deltas, instSettings, settingKey, settings, _i, _len, _ref;
    cdfType = typeRegistery.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    instSettings = cdfNode.s;
    settings = {};
    settings.t = cdfType.name;
    settings.s = {
      url: instSettings.url,
      method: instSettings.method,
      timeout: instSettings.timeout
    };
    if (instSettings.values) {
      settings.s.values = instSettings.values;
    }
    if (instSettings.targets) {
      settings.s.targets = instSettings.targets;
    }
    _ref = ["loading", "error", "complete"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      settingKey = _ref[_i];
      deltas = instSettings[settingKey];
      if (!deltas) {
        continue;
      }
      settings.s[settingKey] = (function() {
        var _j, _len1, _ref1, _results;
        _results = [];
        for (_j = 0, _len1 = deltas.length; _j < _len1; _j++) {
          _ref1 = deltas[_j], cssSelector = _ref1[0], deltaNode = _ref1[1];
          deltaType = typeRegistery.getType(deltaNode);
          deltaSettings = deltaType.deltaSettings(deltaNode, buildState);
          _results.push([cssSelector, deltaSettings]);
        }
        return _results;
      })();
    }
    return settings;
  };

  updateBehavior = function() {
    var base;
    base = baseBehavior.base();
    base.name = "update";
    base.clientScripts.push("behaviors/update");
    base.clientScripts.push("deltas/structure");
    base.clientScripts.push("deltas/attributes");
    base.requiredSettings.push("url");
    base.defaultSettings = {
      method: "GET",
      timeout: 10
    };
    base.validSettings = {
      url: "local url",
      method: ["GET", "POST"],
      loading: "array:array",
      error: "array:array",
      complete: "array:array",
      targets: "array:css sel",
      timeout: "uint",
      values: "array:array"
    };
    base.validationFunctions.push(validateErrorDeltas);
    base.validationFunctions.push(validateLoadingDeltas);
    base.validationFunctions.push(validateCompleteDeltas);
    base.validationFunctions.push(validateValuesSetting);
    base.behaviorSettings = updateBehaviorSettings;
    base.childNodes = updateBehaviorChildNodes;
    return base;
  };

  module.exports = {
    update: updateBehavior
  };

}).call(this);
