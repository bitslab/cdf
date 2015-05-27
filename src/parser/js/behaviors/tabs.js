(function() {
  "use strict";
  var base, elementsHelpers, tabs, validators;

  base = require("./base");

  elementsHelpers = require("../utilities/elements");

  validators = require("../utilities/validation");

  tabs = function() {
    var aBehavior;
    aBehavior = base.base();
    aBehavior.name = "tabs";
    aBehavior.attachableTypes = ["ul", "ol"];
    aBehavior.validate = function(cdfObject, settings, cdfDocument) {
      var elmWithId, err, error, isValid, k, v, _ref, _ref1;
      err = base.errorHeader(cdfObject, aBehavior);
      _ref = base.baseValidation(cdfObject, aBehavior), isValid = _ref[0], error = _ref[1];
      if (!isValid) {
        err += error;
        return [false, err];
      }
      _ref1 = settings.map;
      for (k in _ref1) {
        v = _ref1[k];
        if (typeof v !== "string") {
          err += "value for key " + k + " in settings object is not a string";
          return [false, err];
        }
        elmWithId = elementsHelpers.objectForId(cdfDocument, k);
        if (!elmWithId) {
          err += "unable to find element with " + k + " in document";
          return [false, err];
        }
        if (elmWithId.t !== "li") {
          err += "element with id " + k + " is type " + elmWithId.t + ", must be 'li'";
          return [false, err];
        }
        if (!elementsHelpers.isImmediateChildOf(cdfObject, elmWithId)) {
          err += "li element with id " + k + " is not an immediate child";
          return [false, err];
        }
        if (!elementsHelpers.objectForId(cdfDocument, v)) {
          err += "unable to find element with '" + v + "' in document";
          return [false, err];
        }
      }
      return [true, null];
    };
    aBehavior.clientSettings = function(cdfObject, settings) {
      return {
        id: cdfObject.a.id,
        map: settings.map
      };
    };
    return aBehavior;
  };

  module.exports = {
    tabs: tabs
  };

}).call(this);
