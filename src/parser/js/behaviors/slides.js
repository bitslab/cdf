(function() {
  "use strict";
  var base, behaviorDefaults, behaviorSettingTypes, elementsHelpers, slides, validators;

  base = require("./base");

  elementsHelpers = require("../utilities/elements");

  validators = require("../utilities/validation");

  behaviorDefaults = {
    initial: 0,
    "class": "active",
    wrap: false,
    autoadvance: 0
  };

  behaviorSettingTypes = {
    initial: "int",
    wrap: "bool",
    "class": "html class",
    advancer: "html class",
    retreater: "html class",
    endRangeClass: "html class",
    autoadvance: "int"
  };

  slides = function() {
    var aBehavior;
    aBehavior = base.base();
    aBehavior.name = "slides";
    aBehavior.attachableTypes = ["ul", "ol"];
    aBehavior.validate = function(cdfObject, settings, cdfDocument) {
      var areValidSettings, c, config, err, error, initialValue, isValid, nonLiChilds, settingsError, _ref, _ref1;
      config = base.setDefaults(settings, behaviorDefaults);
      err = base.errorHeader(cdfObject, aBehavior);
      _ref = base.baseValidation(cdfObject, aBehavior), isValid = _ref[0], error = _ref[1];
      if (!isValid) {
        err += error;
        return [false, err];
      }
      _ref1 = validators.areValidSettings(config, behaviorSettingTypes), areValidSettings = _ref1[0], settingsError = _ref1[1];
      if (!areValidSettings) {
        err += settingsError;
        return [false, err];
      }
      if (!cdfObject.c) {
        err += "has no children";
        return [false, err];
      }
      nonLiChilds = (function() {
        var _i, _len, _ref2, _results;
        _ref2 = cdfObject.c;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          c = _ref2[_i];
          if (c.t !== "li") {
            _results.push(c.t);
          }
        }
        return _results;
      })();
      if (nonLiChilds.length > 0) {
        err += "has children of type other than 'li' (ex: '" + nonLiChilds[0] + "')";
        return [false, err];
      }
      initialValue = config.initial;
      if (initialValue < 0 || initialValue >= cdfObject.c.length) {
        err += "'initial' value '" + v + "' is out of the range of children";
        return [false, err];
      }
      if (config.autoadvance < 0) {
        err += "Invalid negative number for milisecs between auto advances";
        return [false, err];
      }
      return [true, null];
    };
    aBehavior.clientSettings = function(cdfObject, settings) {
      var config;
      config = base.setDefaults(settings, behaviorDefaults);
      config.id = cdfObject.a.id;
      return config;
    };
    return aBehavior;
  };

  module.exports = {
    slides: slides
  };

}).call(this);
