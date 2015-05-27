(function() {
  "use strict";
  var cdfTypeCache, flowEvents, getType, timerEvents,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  flowEvents = require("./flow");

  timerEvents = require("./timer");

  cdfTypeCache = {};

  getType = function(typeName) {
    var cdfType;
    if (cdfTypeCache[typeName] !== void 0) {
      return cdfTypeCache[typeName];
    }
    cdfType = null;
    cdfType = (function() {
      switch (false) {
        case __indexOf.call(flowEvents.types, typeName) < 0:
          return flowEvents[typeName]();
        case __indexOf.call(timerEvents.types, typeName) < 0:
          return timerEvents[typeName]();
      }
    })();
    if (!cdfType) {
      throw Error("No event type definition for type '" + typeName + "'");
    }
    cdfTypeCache[typeName] = cdfType;
    return cdfType;
  };

  module.exports = {
    getType: getType,
    elementEvents: flowEvents.types.concat(timerEvents.types)
  };

}).call(this);
