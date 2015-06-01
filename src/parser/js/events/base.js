(function() {
  "use strict";
  var addParentConnectionToBehaviors, baseDefinition, baseEvent, clone, elementConstants, eventChildNodes, eventRender, renderUtils, typeRegistry, validateHasBehaviors, validators;

  typeRegistry = require("../utilities/type-registry");

  elementConstants = require("../elements/constants");

  validators = require("../utilities/validation");

  renderUtils = require("../utilities/render");

  baseDefinition = require("../base");

  clone = require('clone');

  eventChildNodes = function(cdfNode) {
    return cdfNode.b;
  };

  eventRender = function(cdfNode, buildState) {
    var behaviorSettings, cdfType, childBehaviors;
    cdfType = typeRegistry.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    childBehaviors = cdfType.childNodes(cdfNode);
    behaviorSettings = childBehaviors.map(function(childNode) {
      var childType;
      childType = typeRegistry.getType(childNode);
      return childType.behaviorSettings(childNode, buildState);
    });
    return buildState.addEvent({
      t: cdfType.name,
      s: clone(cdfNode.s),
      b: behaviorSettings
    });
  };

  addParentConnectionToBehaviors = function(cdfNode, buildState) {
    var bInst, cdfType, _i, _len, _ref, _results;
    cdfType = typeRegistry.getType(cdfNode);
    _ref = cdfType.childNodes(cdfNode);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bInst = _ref[_i];
      _results.push(bInst._parent = cdfNode);
    }
    return _results;
  };

  validateHasBehaviors = function(cdfNode, buildState) {
    var err;
    if (!cdfNode.b || cdfNode.b.length === 0) {
      err = "'" + cdfNode.t + "' has no behaviors attached to it.  All events must have at least one associated behavior";
      return errors.generateErrorWithTrace(err, cdfNode);
    }
    return [true, null];
  };

  baseEvent = function() {
    var base;
    base = baseDefinition.base();
    base.preprocessingFunctions.push(addParentConnectionToBehaviors);
    base.validationFunctions.push(validateHasBehaviors);
    base.validProperties.b = "array:object";
    base.requriedProperties = ["b"];
    base.childNodes = eventChildNodes;
    base.render = eventRender;
    return base;
  };

  module.exports = {
    base: baseEvent
  };

}).call(this);
