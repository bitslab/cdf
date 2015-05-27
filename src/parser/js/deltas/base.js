(function() {
  "use strict";
  var baseType, clone, deltaBase, deltaSettings, typeRegistery;

  typeRegistery = require("../utilities/type-registery");

  baseType = require("../base");

  clone = require("clone");

  deltaSettings = function(cdfNode, buildState) {
    var cdfType, settings;
    cdfType = typeRegistery.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    settings = {
      t: cdfNode.t,
      s: clone(cdfNode.s)
    };
    return settings;
  };

  deltaBase = function() {
    var base;
    base = baseType.base();
    base.requiredProperties.push("s");
    base.requiredSettings.push("change");
    base.deltaSettings = deltaSettings;
    return base;
  };

  module.exports = {
    base: deltaBase
  };

}).call(this);
