(function() {
  "use strict";
  var baseBehavior, errors, modifyTimerBehavior, modifyTimersSettings, typeRegistery, validation;

  errors = require("../utilities/errors");

  validation = require("../utilities/validation");

  baseBehavior = require("./base");

  typeRegistery = require("../utilities/type-registery");

  modifyTimersSettings = function(cdfNode, buildState) {
    var behaviorSettings, cdfType;
    cdfType = typeRegistery.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    behaviorSettings = {
      t: cdfType.name,
      s: cdfNode.s
    };
    return behaviorSettings;
  };

  modifyTimerBehavior = function() {
    var base;
    base = baseBehavior.base();
    base.name = "modify-timer";
    base.clientScripts.push("behaviors/modify-timer");
    base.requiredSettings.push("timerId");
    base.requiredSettings.push("action");
    base.validSettings = {
      timerId: "string",
      action: ["start", "stop", "reset"]
    };
    base.behaviorSettings = modifyTimersSettings;
    return base;
  };

  module.exports = {
    "modify-timer": modifyTimerBehavior
  };

}).call(this);
