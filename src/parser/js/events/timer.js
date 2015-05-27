(function() {
  "use strict";
  var baseEvent, timer, validateTimerId;

  baseEvent = require("./base");

  validateTimerId = function(cdfNode, buildState) {
    var error, timerId, timerIdRegistery;
    timerIdRegistery = buildState.config("timerIdRegistery");
    timerId = cdfNode.s.timerId;
    if (timerIdRegistery[timerId]) {
      error = "Found duplicate timer ids: '" + timerId + "'";
      return [false, error];
    }
    return [true, null];
  };

  timer = function() {
    var base;
    base = baseEvent.base();
    base.name = "timer";
    base.clientScripts.push("events/timer");
    base.requiredSettings = ["ms", "timerId"];
    base.defaultSettings.immediate = true;
    base.validSettings.ms = "int";
    base.validSettings.repeat = "bool";
    base.validSettings.timerId = "string";
    base.validSettings.immediate = "bool";
    base.validationFunctions.push(validateTimerId);
    return base;
  };

  module.exports.timer = timer;

}).call(this);
