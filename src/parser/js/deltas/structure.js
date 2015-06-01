(function() {
  "use strict";
  var baseDelta, buildTools, errorHanding, iter, removeSubtree, removeSubtreeDeltaSettings, typeRegistry, updateSubtree, updateTreeDeltaChildNodes, updateTreeDeltaSettings, validateAChangeNode, validateChangeNodes, _renderHtmlForChildNodes;

  baseDelta = require("../base");

  buildTools = require("../utilities/build-tools");

  typeRegistry = require("../utilities/type-registry");

  iter = require("../utilities/iteration");

  errorHanding = require("../utilities/errors");

  removeSubtreeDeltaSettings = function(cdfNode, buildState) {
    var cdfType, settings;
    cdfType = typeRegistry.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    settings = {
      t: cdfType.name,
      s: {
        inclusive: cdfNode.s.inclusive
      }
    };
    return settings;
  };

  removeSubtree = function() {
    var base;
    base = baseDelta.base();
    base.name = "remove-subtree";
    base.clientScripts.push("deltas/structure");
    base.defaultSettings.inclusive = false;
    base.validSettings.inclusive = "bool";
    base.deltaSettings = removeSubtreeDeltaSettings;
    return base;
  };

  _renderHtmlForChildNodes = function(cdfNode) {
    var cdfType, subTreebuildState;
    subTreebuildState = buildTools.makeBuildState();
    cdfType = typeRegistry.getType(cdfNode);
    cdfType.render(cdfNode, subTreebuildState);
    return subTreebuildState.html();
  };

  updateTreeDeltaSettings = function(cdfNode, buildState) {
    var buildStateHtml, cdfType, children, settings;
    cdfType = typeRegistry.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    children = cdfType.childNodes(cdfNode);
    buildStateHtml = children.map(_renderHtmlForChildNodes);
    settings = {};
    settings.t = cdfType.name;
    settings.s = {
      action: cdfNode.s.action,
      change: buildStateHtml.join("\n")
    };
    return settings;
  };

  updateTreeDeltaChildNodes = function(cdfNode) {
    return cdfNode.s.change;
  };

  validateAChangeNode = function(cdfNode) {
    var children, error, nodeType;
    nodeType = typeRegistry.getType(cdfNode);
    if (!nodeType) {
      error = "Found declared type of '" + nodeTypeName + "' for subtree in update-tree delta, which does not match a known element type.";
      return generateErrorWithTrace(error, cdfNode);
    }
    if (!nodeType.mayAppearInSubtrees) {
      error = "CDF type '" + cdfType.name + "' is not valid to include in subtrees";
      return generateErrorWithTrace(error, cdfNode);
    }
    children = nodeType.childNodes(cdfNode);
    return iter.reduce(children, validateAChangeNode);
  };

  validateChangeNodes = function(cdfNode, buildState) {
    return iter.reduce(cdfNode.s.change, validateAChangeNode);
  };

  updateSubtree = function(deltaName) {
    var base;
    base = baseDelta.base();
    base.name = "update-subtree";
    base.clientScripts.push("deltas/structure");
    base.validSettings.action = ["append", "prepend", "replace", "replace-sub"];
    base.requiredSettings.push("action");
    base.validSettings.change = "array";
    base.requiredSettings.push("change");
    base.validationFunctions.push(validateChangeNodes);
    base.childNodes = updateTreeDeltaChildNodes;
    base.deltaSettings = updateTreeDeltaSettings;
    return base;
  };

  module.exports = {
    "remove-subtree": removeSubtree,
    "update-subtree": updateSubtree
  };

}).call(this);
