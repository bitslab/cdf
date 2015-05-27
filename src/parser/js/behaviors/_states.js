(function() {
  "use strict";
  var base, behaviorSettingTypes, elementConstants, elementsHelpers, states, statesDefaults, validElmChangeKeys, validStateEvents, validateStatesForEvent, validators,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  base = require("./base");

  elementsHelpers = require("../utilities/elements");

  elementConstants = require("../elements/constants");

  validators = require("../utilities/validation");

  statesDefaults = {
    wrap: false
  };

  behaviorSettingTypes = {
    wrap: "bool",
    states: "array:delta"
  };

  validStateEvents = ["click", "dblclick", "hover", "mouseover", "mouseout", "change", "appeared", "disappear"];

  validElmChangeKeys = ["add", "remove"];

  validateStatesForEvent = function(eventName, stateChanges) {
    var aClass, badKeys, classError, cssSelector, elmChanges, error, isValid, isValidClass, k, selectorError, stateChange, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
    if (__indexOf.call(validStateEvents, eventName) < 0) {
      return [false, "Invalid event specified: '" + eventName + "'"];
    }
    for (_i = 0, _len = stateChanges.length; _i < _len; _i++) {
      stateChange = stateChanges[_i];
      for (cssSelector in stateChange) {
        elmChanges = stateChange[cssSelector];
        _ref = validators.isSafeCSSSelector(cssSelector), isValid = _ref[0], selectorError = _ref[1];
        if (!isValid) {
          selectorError += " (" + [eventName, cssSelector].join(" -> ");
          selectorError += ")";
          return [false, selectorError];
        }
        _ref1 = elmChanges.keys;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          k = _ref1[_j];
          if (__indexOf.call(validElmChangeKeys, k) < 0) {
            badKeys = k;
          }
        }
        if (badKeys.length !== 2) {
          error = "Unexpected keys in state description: (";
          error += [eventName, cssSelector, badKeys.join(", ")].join(" -> ");
          error += ")";
          return [false, error];
        }
        _ref2 = [
          (function() {
            var _l, _len2, _results;
            _results = [];
            for (_l = 0, _len2 = validElmChangeKeys.length; _l < _len2; _l++) {
              k = validElmChangeKeys[_l];
              _results.push(elmChanges[k] || []);
            }
            return _results;
          })()
        ];
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          aClass = _ref2[_k];
          _ref3 = isValidHtmlClass(aClass), isValidClass = _ref3[0], classError = _ref3[1];
          if (!isValidClass) {
            classError += " (" + [eventName, cssSelector].join(" -> ");
            classError += ")";
            return [false, classError];
          }
        }
      }
    }
    return [true, null];
  };

  states = function() {
    var aBehavior;
    aBehavior = base.base();
    aBehavior.name = "states";
    aBehavior.attachableTypes = elementConstants.flowTypes;
    aBehavior.validate = function(cdfObject, settings, cdfDocument) {
      var changesErr, err, error, eventName, eventSettings, isValid, settingsError, _ref, _ref1, _ref2;
      err = base.errorHeader(cdfObject, aBehavior);
      _ref = base.baseValidation(cdfObject, aBehavior), isValid = _ref[0], error = _ref[1];
      if (!isValid) {
        err += error;
        return [false, err];
      }
      for (eventName in settings) {
        eventSettings = settings[eventName];
        _ref1 = validators.areValidSettings(eventSettings, behaviorSettingTypes), isValid = _ref1[0], settingsError = _ref1[1];
        if (!isValid) {
          err += settingsError;
          return [false, err];
        }
        _ref2 = validateStatesForEvent(eventName, eventSettings), isValid = _ref2[0], changesErr = _ref2[1];
        if (!isValid) {
          return [false, changesErr];
        }
      }
      return [true, null];
    };
    aBehavior.clientSettings = function(cdfObject, settings) {
      var config, eventName, eventSettings;
      config = {};
      config.id = cdfObject.a.id;
      config.events = {};
      for (eventName in settings) {
        eventSettings = settings[eventName];
        config.events[eventName] = base.setDefaults(eventSettings);
      }
      return config;
    };
    return aBehavior;
  };

  module.exports.states = states;

}).call(this);
