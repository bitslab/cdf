(function() {
  "use strict";
  var crisp, eventRegistery, makeTimer, timerRegistery;

  crisp = window.CRISP;

  eventRegistery = crisp.events;

  timerRegistery = {};

  makeTimer = function(timerSettings, cb) {
    var cancelFunc, executionFunc, intervalInMs, isCurrentlyRunning, repeats, startFunc, timeoutId, timerName, timerObject;
    timeoutId = null;
    intervalInMs = timerSettings.ms;
    timerName = timerSettings.timerId;
    repeats = timerSettings.repeat;
    cancelFunc = null;
    startFunc = null;
    if (repeats) {
      cancelFunc = window.clearInterval;
      startFunc = window.setInterval;
    } else {
      cancelFunc = window.clearTimeout;
      startFunc = window.setTimeout;
    }
    isCurrentlyRunning = function() {
      return !!timeoutId;
    };
    executionFunc = function() {
      if (!repeats) {
        timeoutId = null;
      }
      return cb();
    };
    timerObject = {
      cancel: function() {
        if (!isCurrentlyRunning()) {
          return;
        }
        cancelFunc(timeoutId);
        return timeoutId = null;
      },
      start: function() {
        if (isCurrentlyRunning()) {
          return;
        }
        return timeoutId = startFunc(executionFunc, intervalInMs);
      },
      cancelAndStart: function() {
        timerObject.cancel();
        return timerObject.start();
      }
    };
    return timerObject;
  };

  eventRegistery.timer = function(elm, settings, cb) {
    var timerId, timerObject;
    timerId = settings.timerId;
    timerObject = timerRegistery[timerId];
    if (settings.immediate) {
      return timerObject.start();
    }
  };

  eventRegistery.timer.register = function(elm, settings, cb) {
    var timerId;
    timerId = settings.timerId;
    return timerRegistery[timerId] = makeTimer(settings, cb);
  };

  eventRegistery.timer.timerRegistery = timerRegistery;

}).call(this);
