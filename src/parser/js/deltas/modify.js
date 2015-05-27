(function() {
  "use strict";
  var baseDelta, classes, properties,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  baseDelta = require("../base");

  classes = function(deltaName) {
    var base;
    base = baseDelta.base();
    base.name = deltaName;
    base.validProperties.c = "array:html class";
    base.requriedProperties.push("c");
    base.validSettings.action = ["add", "remove"];
    base.requiredSettings.push("action");
    return base;
  };

  properties = function() {
    var allowedProperties, base;
    base = baseDelta.base();
    base.name = "properties";
    base.validSettings.action = ["add", "remove"];
    base.requiredSettings.push("action");
    base.validProperties.c = "object";
    base.requriedProperties.push("c");
    allowedProperties = ["value", "disabled", "readonly", "selected", "clicked", "src", "alt"];
    base.validationFunctions.push(function(cdfType, cdfNode, cdfDoc) {
      var key, value, _ref;
      _ref = cdfNode.c;
      for (key in _ref) {
        value = _ref[key];
        if (__indexOf.call(allowedProperties, key) < 0) {
          return [false, "'" + key + "' isn't a property that is valid to edit with a 'properties' delta"];
        }
      }
      return [true, null];
    });
    return base;
  };

  module.exports = {
    classes: classes,
    properties: properties
  };

}).call(this);
