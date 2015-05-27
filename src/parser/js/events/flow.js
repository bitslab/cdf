(function() {
  "use strict";
  var appear, attachEventsToParents, baseEvent, basicFlowEvent, disappear, keyboardBasedEvent, mouseClickBased, mouseMovementBased, registerType, typeRegistery, validateParentIds;

  typeRegistery = require("../utilities/type-registery");

  baseEvent = require("./base");

  registerType = (typeRegistery.sharedInstance()).registerType;

  attachEventsToParents = function(cdfType, cdfNode, buildState) {
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

  validateParentIds = function(cdfType, cdfNode, buildState) {
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
    var keyboardEventType;
    keyboardEventType = function() {
      var base;
      base = basicFlowEvent(eventName);
      base.clientScripts.push("events/basic");
      base.validSettings.keyCodes = "array:int";
      base.render = render;
      return base;
    };
    registerType(eventName, keyboardEventType);
    return keyboardEventType;
  };

  mouseClickBased = function(eventName) {
    var mouseClickEventType;
    mouseClickEventType = function() {
      var base;
      base = basicFlowEvent(eventName);
      base.clientScripts.push("events/basic");
      base.validSettings.button = ["left", "middle", "right"];
      return base;
    };
    registerType(eventName, mouseClickEventType);
    return mouseClickEventType;
  };

  mouseMovementBased = function(eventName) {
    var mouseMovementEventType;
    mouseMovementEventType = function() {
      var base;
      base = basicFlowEvent(eventName);
      base.clientScripts.push("events/basic");
      return base;
    };
    registerType(eventName, mouseMovementEventType);
    return mouseMovementEventType;
  };

  appear = function() {
    var base;
    base = basicFlowEvent();
    base.name = "appear";
    base.clientScripts.push("contrib/jquery.appear");
    base.clientScripts.push("events/appear");
    return base;
  };

  registerType("appear", appear);

  disappear = function() {
    var base;
    base = basicFlowEvent();
    base.name = "disappear";
    base.clientScripts.push("contrib/jquery.appear");
    base.clientScripts.push("events/appear");
    return base;
  };

  registerType("disappear", disappear);

  module.exports = {
    click: mouseClickBased("click"),
    doubleclick: mouseClickBased("doubleclick"),
    disappear: disappear,
    appear: appear,
    mouseenter: mouseMovementBased("mouseenter"),
    mouseleave: mouseMovementBased("mouseleave"),
    mouseover: mouseMovementBased("mouseover"),
    mouseout: mouseMovementBased("mouseout"),
    keyup: keyboardBasedEvent("keyup"),
    keydown: keyboardBasedEvent("keydown")
  };

}).call(this);
