(function() {
  "use strict";
  var allowedProperties, baseDelta, classes, properties, validateAffectedProperties, validation,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  validation = require("../utilities/validation");

  baseDelta = require("./base");

  validateAffectedProperties = function(cdfNode, buildState) {
    var key, value, _ref;
    _ref = cdfNode.c;
    for (key in _ref) {
      value = _ref[key];
      if (__indexOf.call(allowedProperties, key) < 0) {
        return [false, "'" + key + "' isn't a property that is valid to edit with a 'properties' delta"];
      }
    }
    return [true, null];
  };

  classes = function() {
    var base;
    base = baseDelta.base();
    base.name = "classes";
    base.clientScripts.push("deltas/attributes");
    base.defaultSettings.action = "add";
    base.validSettings.action = ["add", "remove"];
    base.requiredSettings.push("change");
    base.validSettings.change = "array:html class";
    return base;
  };

  allowedProperties = ["value", "disabled", "readonly", "selected", "clicked", "src", "alt"];

  properties = function() {
    var base;
    base = baseDelta.base();
    base.name = "properties";
    base.clientScripts.push("deltas/attributes");
    base.defaultSettings.change = {};
    base.requiredSettings.push("change");
    base.validSettings.change = "object";
    base.validationFunctions.push(validateAffectedProperties);
    return base;
  };

  module.exports = {
    classes: classes,
    properties: properties
  };

}).call(this);
