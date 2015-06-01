(function() {
  "use strict";
  var addHtmlIdsWhereEvents, addParentConnectionToChildren, baseElement, cdfBase, consts, elementChildNodes, elementRender, errors, escape, iter, renderEndTag, renderSettingsAsAttributes, renderStartTag, renderUtils, typeRegistry, uuid, validateChildElms, validateUniqueIds, validators, _isValidChild,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  consts = require("./constants");

  validators = require("../utilities/validation");

  errors = require("../utilities/errors");

  renderUtils = require("../utilities/render");

  typeRegistry = require("../utilities/type-registry");

  iter = require("../utilities/iteration");

  cdfBase = require("../base");

  escape = require("escape-html");

  uuid = require("node-uuid");

  addParentConnectionToChildren = function(cdfNode, buildState) {
    var children, nodeType;
    nodeType = typeRegistry.getType(cdfNode);
    children = nodeType.childNodes(cdfNode);
    return children.forEach(function(childNode) {
      return childNode._parent = cdfNode;
    });
  };

  addHtmlIdsWhereEvents = function(cdfNode, buildState) {
    if (!cdfNode.e || cdfNode.e.length === 0) {
      return;
    }
    if (!cdfNode.s) {
      cdfNode.s = {};
    }
    if (!cdfNode.s.id) {
      return cdfNode.s.id = "cdf-" + (uuid.v4());
    }
  };

  validateUniqueIds = function(cdfNode, buildState) {
    var currentElementId, err, existingIds;
    if (!cdfNode.s || !cdfNode.s.id) {
      return [true, null];
    }
    currentElementId = cdfNode.s.id;
    existingIds = buildState.config("ids");
    if (existingIds[currentElementId]) {
      err = "Found duplicate usage of id '" + currentElementId + "'";
      return errors.generateErrorWithTrace(err, cdfNode);
    }
    existingIds[currentElementId] = true;
    return [true, null];
  };

  validateChildElms = function(cdfNode, buildState) {
    var cdfType, error, isSuccess, _ref;
    if (cdfNode.c === void 0) {
      return [true, null];
    }
    cdfType = typeRegistry.getType(cdfNode);
    _ref = iter.reduce(cdfNode.c, _isValidChild, cdfType), isSuccess = _ref[0], error = _ref[1];
    if (!isSuccess) {
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return [true, null];
  };

  _isValidChild = function(childElm, parentType) {
    var childType, error, _ref;
    try {
      childType = typeRegistry.getType(childElm);
    } catch (_error) {
      error = _error;
      return [false, error];
    }
    if (_ref = childType.name, __indexOf.call(parentType.validChildElementTypes, _ref) < 0) {
      error = "Element of type '" + childType.name + "' is not valid as a child of a '" + parentType.name + "' instance";
      return [false, error];
    }
    return [true, null];
  };

  elementChildNodes = function(cdfNode) {
    var elementNodes, eventNodes;
    elementNodes = Array.isArray(cdfNode.c) ? cdfNode.c : [];
    eventNodes = Array.isArray(cdfNode.e) ? cdfNode.e : [];
    return elementNodes.concat(eventNodes);
  };

  elementRender = function(cdfNode, buildState) {
    var endTag, startTag;
    startTag = renderStartTag(cdfNode);
    buildState.addHtml(startTag);
    cdfBase.render(cdfNode, buildState);
    endTag = renderEndTag(cdfNode);
    return buildState.addHtml(endTag);
  };

  renderSettingsAsAttributes = function(cdfNode) {
    var attrString, attrStrings, safeValue, settingName, settingValue;
    attrString = "";
    if (cdfNode.s === void 0) {
      return attrString;
    }
    attrStrings = (function() {
      var _ref, _results;
      _ref = cdfNode.s;
      _results = [];
      for (settingName in _ref) {
        settingValue = _ref[settingName];
        safeValue = (function() {
          switch (false) {
            case settingName !== "id":
              return settingValue;
            case settingName !== "class":
              return settingValue.join(" ");
            default:
              return escape(settingValue);
          }
        })();
        _results.push("" + settingName + "=\"" + safeValue + "\"");
      }
      return _results;
    })();
    return attrStrings.join(" ");
  };

  renderStartTag = function(cdfNode) {
    var attrString, cdfType;
    cdfType = typeRegistry.getType(cdfNode);
    attrString = renderSettingsAsAttributes(cdfNode);
    if (attrString) {
      attrString = " " + attrString;
    }
    return "<" + cdfType.name + attrString + ">";
  };

  renderEndTag = function(cdfNode) {
    var cdfType;
    cdfType = typeRegistry.getType(cdfNode);
    if (cdfType.isSelfClosing) {
      return "";
    } else {
      return "</" + cdfType.name + ">";
    }
  };

  baseElement = function() {
    var base;
    base = cdfBase.base();
    base.mayAppearInSubtrees = true;
    base.isSelfClosing = false;
    base.validChildElementTypes = [];
    base.preprocessingFunctions.push(addParentConnectionToChildren);
    base.preprocessingFunctions.push(addHtmlIdsWhereEvents);
    base.validationFunctions.push(validateChildElms);
    base.validProperties.e = "array:object";
    base.validProperties.c = "array:object";
    base.validSettings = {
      id: "html id",
      "class": "array:html class",
      role: "string"
    };
    base.childNodes = elementChildNodes;
    base.render = elementRender;
    return base;
  };

  module.exports = {
    renderStartTag: renderStartTag,
    renderEndTag: renderEndTag,
    base: baseElement
  };

}).call(this);
