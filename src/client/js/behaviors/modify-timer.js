(function() {
  "use strict";
  var behaviorRegistery, crisp;

  crisp = window.CRISP;

  behaviorRegistery = crisp.behaviors;

  behaviorRegistery["modify-timer"] = function(settings) {
    var timerId, timerObj, timerRegistery;
    timerRegistery = crisp.events.timer.timerRegistery;
    timerId = settings.timerId;
    timerObj = timerRegistery[timerId];
    if (!timerObj) {
      throw "A modify-timer behavior instance tried to modify a timer with ID '" + timerId + "' that does not corespond to an existing timer object.";
    }
    switch (settings.action) {
      case "start":
        return timerObj.start();
      case "stop":
        return timerObj.cancel();
      case "reset":
        return timerObj.cancelAndStart();
    }
  };

}).call(this);
