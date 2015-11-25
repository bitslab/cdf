(function() {
  "use strict";
  var addKeyboardEvent, addMouseClickEvent, addMouseMovementEvent, appearPluginEvents, eventsRegistery,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  eventsRegistery = window.CRISP.events;

  appearPluginEvents = function(eventName) {
    return eventsRegistery[eventName] = function(elm, settings, cb) {
      elm.on(eventName, function(event, newElements) {
        cb();
        return false;
      });
      return elm.appear();
    };
  };

  addKeyboardEvent = function(eventName) {
    return eventsRegistery[eventName] = function(elm, settings, cb) {
      return elm.on(eventName, function(event) {
        var _ref;
        if (settings.keyCodes && (_ref = event.which, __indexOf.call(settings.keyCodes, _ref) < 0)) {
          return false;
        }
        cb();
        return false;
      });
    };
  };

  addMouseClickEvent = function(eventName) {
    return eventsRegistery[eventName] = function(elm, settings, cb) {
      var mouseTarget;
      mouseTarget = (function() {
        switch (false) {
          case settings.button !== "left":
            return 1;
          case settings.button !== "middle":
            return 2;
          case settings.button !== "right":
            return 3;
          default:
            return null;
        }
      })();
      return elm.on(eventName, function(event) {
        if (mouseTarget) {
          if (event.which !== mouseTarget) {
            return false;
          }
        }
        cb();
        return false;
      });
    };
  };

  addMouseMovementEvent = function(eventName) {
    return eventsRegistery[eventName] = function(elm, settings, cb) {
      return elm.on(eventName, function(event) {
        cb();
        return false;
      });
    };
  };

  ["mouseenter", "mouseleave", "mouseover", "mouseout"].forEach(addMouseMovementEvent);

  ["keyup", "keydown"].forEach(addKeyboardEvent);

  ["click", "doubleclick"].forEach(addMouseClickEvent);

  ["appear", "disappear"].forEach(appearPluginEvents);

}).call(this);
