(function() {
  var bindEventInstances, crisp, registerBehaviorInstance, triggerBehaviorInstance;

  crisp = window.CRISP = {
    behaviors: {},
    deltas: {},
    events: {},
    utils: {}
  };

  crisp.utils.bindDelta = function(cssSelector, deltaInst) {
    var deltaName, deltaSettings, deltaType;
    deltaName = deltaInst.t;
    deltaSettings = deltaInst.s;
    deltaType = crisp.deltas[deltaName];
    if (!deltaType) {
      throw "Unable to find definition for delta: '" + deltaName + "'";
    }
    return function() {
      var jqueryWrappedDomNodes;
      jqueryWrappedDomNodes = jQuery(cssSelector);
      return deltaType(deltaSettings, jqueryWrappedDomNodes);
    };
  };

  registerBehaviorInstance = function(behaviorInst) {
    var behaviorName, behaviorSettings, behaviorType;
    behaviorName = behaviorInst.t;
    behaviorSettings = behaviorInst.s;
    behaviorType = crisp.behaviors[behaviorName];
    if (behaviorType.register) {
      return behaviorType.register(behaviorSettings);
    }
  };

  triggerBehaviorInstance = function(behaviorInst) {
    var behaviorName, behaviorSettings, behaviorType;
    behaviorName = behaviorInst.t;
    behaviorSettings = behaviorInst.s;
    behaviorType = crisp.behaviors[behaviorName];
    if (!behaviorType) {
      throw "Unable to find definition for behavior: '" + behaviorName + "'";
    }
    return behaviorType(behaviorSettings);
  };

  bindEventInstances = function(eventInst) {
    var $targetElm, callbackFunc, childBehaviors, cleanSettings, eventName, eventSettings, eventType, targetElm, targetId;
    eventName = eventInst.t;
    eventSettings = eventInst.s;
    childBehaviors = eventInst.b;
    childBehaviors.forEach(registerBehaviorInstance);
    eventType = crisp.events[eventName];
    if (!eventType) {
      throw "Unable to find definition for event '" + eventName + "'";
    }
    targetId = eventSettings.targetId;
    if (!targetId) {
      $targetElm = null;
      cleanSettings = eventSettings;
    } else {
      targetElm = document.getElementById(targetId);
      if (!targetElm) {
        throw "Unable to find an element with ID '" + targetId + "' to bind an instance of the '" + eventName + "' event to.";
      }
      $targetElm = $(targetElm);
      cleanSettings = Object.create(eventSettings);
      delete cleanSettings.targetId;
    }
    callbackFunc = function() {
      return childBehaviors.forEach(triggerBehaviorInstance);
    };
    if (eventType.register) {
      eventType.register($targetElm, cleanSettings, callbackFunc);
    }
    return eventType($targetElm, cleanSettings, callbackFunc);
  };

  jQuery(function($) {
    return crisp.eventInstances.forEach(bindEventInstances);
  });

}).call(this);
