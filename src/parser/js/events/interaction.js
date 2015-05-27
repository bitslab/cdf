(function() {
  "use strict";
  var appearanceBasedEvent, attachEventsToParents, baseEvent, basicFlowEvent, keyboardBasedEvent, mouseClickBased, mouseMovementBased, validateParentIds;

  baseEvent = require("./base");

  attachEventsToParents = function(cdfNode, buildState) {
    var parentId, parentNode;
    parentNode = cdfNode._parent;
    if (!parentNode) {
      return;
    }
    parentId = parentNode.s.id;
    if (!parentId) {
      return;
    }
    return cdfNode.s.targetId = parentId;
  };

  validateParentIds = function(cdfNode, buildState) {
    var parentNode;
    parentNode = cdfNode._parent;
    if (!parentNode || !parentNode.s.id) {
      [false, "Parent node does not an an html ID"];
    }
    return [true, null];
  };

  basicFlowEvent = function(eventName) {
    var base;
    base = baseEvent.base();
    base.name = eventName;
    base.validSettings.targetId = "string";
    base.requiredSettings.push("targetId");
    base.preprocessingFunctions.push(attachEventsToParents);
    base.validationFunctions.push(validateParentIds);
    return base;
  };

  keyboardBasedEvent = function(eventName) {
    return function() {
      var base;
      base = basicFlowEvent(eventName);
      base.clientScripts.push("events/basic");
      base.validSettings.keyCodes = "array:int";
      base.render = render;
      return base;
    };
  };

  mouseClickBased = function(eventName) {
    return function() {
      var base;
      base = basicFlowEvent(eventName);
      base.clientScripts.push("events/basic");
      base.validSettings.button = ["left", "middle", "right"];
      return base;
    };
  };

  mouseMovementBased = function(eventName) {
    return function() {
      var base;
      base = basicFlowEvent(eventName);
      base.clientScripts.push("events/basic");
      return base;
    };
  };

  appearanceBasedEvent = function(eventName) {
    return function() {
      var base;
      base = basicFlowEvent();
      base.name = eventName;
      base.clientScripts.push("contrib/jquery.appear");
      base.clientScripts.push("events/basic");
      return base;
    };
  };

  module.exports = {
    click: mouseClickBased("click"),
    doubleclick: mouseClickBased("doubleclick"),
    disappear: appearanceBasedEvent("disappear"),
    appear: appearanceBasedEvent("appear"),
    mouseenter: mouseMovementBased("mouseenter"),
    mouseleave: mouseMovementBased("mouseleave"),
    mouseover: mouseMovementBased("mouseover"),
    mouseout: mouseMovementBased("mouseout"),
    keyup: keyboardBasedEvent("keyup"),
    keydown: keyboardBasedEvent("keydown")
  };

}).call(this);
