(function() {
  "use strict";
  var elementEvents, generalEvents;

  elementEvents = ["click", "doubleclick", "hover", "mouseover", "mouseout", "change", "appeared", "disappear"];

  generalEvents = ["timer", "load"];

  module.exports.events = {
    general: generalEvents,
    element: elementEvents
  };

}).call(this);
