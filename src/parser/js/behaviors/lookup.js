(function() {
  "use strict";
  var definitionCache, getType, statesBehavior, timerBehavior, updateBehavior;

  statesBehavior = require("./states");

  timerBehavior = require("./modify-timer");

  updateBehavior = require("./update");

  definitionCache = {};

  getType = function(behaviorName) {
    var foundBehavior;
    if (definitionCache[behaviorName]) {
      return definitionCache[behaviorName];
    }
    foundBehavior = (function() {
      switch (false) {
        case behaviorName !== "states":
          return statesBehavior.states();
        case behaviorName !== "update":
          return updateBehavior.update();
        case behaviorName !== "modify-timer":
          return timerBehavior["modify-timer"]();
      }
    })();
    if (!foundBehavior) {
      throw Error("No behavior definition for type '" + behaviorName + "'");
    }
    definitionCache[behaviorName] = foundBehavior;
    return foundBehavior;
  };

  module.exports = {
    types: statesBehavior.types.concat(timerBehavior.types, updateBehavior.types),
    getType: getType
  };

}).call(this);
