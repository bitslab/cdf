(function() {
  "use strict";
  var areValidSettings, arrayTools, buildTools, checkTreeForDisallowedProperties, errors, htmlClassPattern, htmlIdPattern, isExpectedType, isSafeCSSSelector, isValidHtmlClass, isValidHtmlId, iter, typeRegistery, url, validCSSSelectorPattern, validateNode, _isValidSetting,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  arrayTools = require("./array");

  iter = require("./iteration");

  errors = require("./errors");

  buildTools = require("./build-tools");

  typeRegistery = require("./type-registery");

  url = require("url");

  htmlIdPattern = /^[A-Za-z]+[A-Za-z0-9_:.-]*$/;

  htmlClassPattern = /^[A-Za-z_]+[A-Za-z0-9_-]*$/;

  validCSSSelectorPattern = /^[\d\s\w.#,-_>]*$/;

  validateNode = function(cdfNode, buildState) {
    var areValid, cdfType, children, error, isSuccess, valFuncs, _ref, _ref1;
    if (!cdfNode || (typeof cdfNode !== 'object')) {
      return [false, "Was passed a non-object, which is trivially not a valid cdf node: '" + cdfNode + "'."];
    }
    try {
      cdfType = typeRegistery.getType(cdfNode);
    } catch (_error) {
      error = _error;
      return [false, error];
    }
    valFuncs = cdfType.validationFunctions;
    _ref = iter.inverseReduce(valFuncs, cdfNode, buildState), isSuccess = _ref[0], error = _ref[1];
    if (!isSuccess) {
      return [false, error];
    }
    children = cdfType.childNodes(cdfNode);
    _ref1 = iter.reduce(children, validateNode, buildState), areValid = _ref1[0], error = _ref1[1];
    if (!areValid) {
      return [false, error];
    }
    return [true, null];
  };

  checkTreeForDisallowedProperties = function(cdfNode) {
    var cdfType, children, error, invalidPropNames, propertyNames;
    propertyNames = Object.keys(cdfNode);
    invalidPropNames = propertyNames.filter(function(aPropertyName) {
      return (aPropertyName[0] === "_") && (aPropertyName !== "_parent");
    });
    if (invalidPropNames.length > 0) {
      error = "Found properties with invalid names: " + (invalidPropNames.join(", "));
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    try {
      cdfType = typeRegistery.getType(cdfNode);
    } catch (_error) {
      error = _error;
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    children = cdfType.childNodes(cdfNode);
    if (!Array.isArray(children)) {
      error = "Received something other than a list when we expected to get an array of child nodes: " + children;
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return iter.reduce(children, checkTreeForDisallowedProperties);
  };

  isSafeCSSSelector = function(selector) {
    if (typeof selector !== "string") {
      return [false, "Given CSS selector is not of type 'string'"];
    }
    if (!selector.match(validCSSSelectorPattern)) {
      return [false, "CSS selector '" + selector + "' contains illegal charaters"];
    }
    return [true, null];
  };

  isValidHtmlId = function(aString) {
    if (typeof aString !== "string") {
      return [false, "Given HTML id '" + aString + "' is not of type 'string'"];
    }
    if (!aString.match(htmlIdPattern)) {
      return [false, "Given HTML id '" + aString + "' is not a valid HTML ID"];
    }
    return [true, null];
  };

  isValidHtmlClass = function(aString) {
    if (typeof aString !== "string") {
      return [false, "Given HTML class '" + aString + "' is not of type 'string'"];
    }
    if (!aString.match(htmlClassPattern)) {
      return [false, "Given HTML class '" + aString + "' is not a valid HTML class"];
    }
    return [true, null];
  };

  areValidSettings = function(settings, settingsDefs, testType) {
    var settingValuePairs;
    if (testType == null) {
      testType = "settings";
    }
    if (settings === void 0) {
      return [true, null];
    }
    if (testType !== "settings" && testType !== "properties") {
      throw "Invalid call to `validation.areValidSettings`.  Called with '" + testType + "', but must be either 'settings' or 'properties'";
    }
    if (settings === null) {
      return [false, "'" + testType + "' must be objects, not 'null'"];
    }
    if (typeof settings !== "object") {
      return [false, "'" + testType + "' must be objects, not '" + (typeof settings) + "'"];
    }
    settingValuePairs = arrayTools.objectToArray(settings);
    return iter.reduce(settingValuePairs, _isValidSetting, settingsDefs, testType);
  };

  _isValidSetting = function(settingPair, settingsDefs, testType) {
    var settingName, settingTypeRequirement, settingValue;
    settingName = settingPair[0], settingValue = settingPair[1];
    if (settingName === "_parent") {
      return [true, null];
    }
    if (settingsDefs[settingName] === void 0) {
      return [false, "'" + testType + "' param '" + settingName + "' is not specified as a known / valid setting / property"];
    }
    settingTypeRequirement = settingsDefs[settingName];
    return isExpectedType(settingValue, settingTypeRequirement);
  };

  isExpectedType = function(value, type) {
    var childErr, childType, classErr, error, idErr, isChildValid, isValidClass, isValidId, isValidSelector, selErr, subError, subValue, urlParts;
    error = (function() {
      var _i, _len, _ref, _ref1, _ref2, _ref3;
      switch (false) {
        case !Array.isArray(type):
          if (__indexOf.call(type, value) < 0) {
            return "'" + value + "' is not one of the valid values: '" + (type.join(", ")) + "'";
          } else {
            return null;
          }
          break;
        case type !== "array":
          if (!Array.isArray(value)) {
            return "'" + value + "' is not an array";
          } else {
            return null;
          }
          break;
        case type !== "object":
          if (typeof value === "object" && value !== null) {
            return null;
          } else {
            return "" + value + " is not an object";
          }
          break;
        case type !== "int" && type !== "uint":
          if (typeof value !== "number" || Math.floor(value !== value)) {
            return "'" + value + "' is not an integer";
          } else if (type === "uint" && value < 0) {
            return "'" + value + "' is not a positive integer";
          } else {
            return null;
          }
          break;
        case type !== "string":
          if (typeof value !== "string") {
            return "'" + value + "' is not a string";
          } else {
            return null;
          }
          break;
        case type !== "bool":
          if (value !== true && value !== false) {
            return "'" + value + "' is not a bool";
          } else {
            return null;
          }
          break;
        case type !== "html class":
          _ref = isValidHtmlClass(value), isValidClass = _ref[0], classErr = _ref[1];
          if (isValidClass) {
            return null;
          } else {
            return classErr;
          }
          break;
        case type !== "html id":
          _ref1 = isValidHtmlId(value), isValidId = _ref1[0], idErr = _ref1[1];
          if (isValidId) {
            return null;
          } else {
            return idErr;
          }
          break;
        case type !== "css sel":
          _ref2 = isSafeCSSSelector(value), isValidSelector = _ref2[0], selErr = _ref2[1];
          if (isValidSelector) {
            return null;
          } else {
            return selErr;
          }
          break;
        case type !== "local url" && type !== "safe url":
          if (typeof type !== "string") {
            return "" + value + " is not a local URL (because it isn't a string)";
          } else {
            urlParts = url.parse(value, false, true);
            if (type === "local url") {
              if (!urlParts.host && !urlParts.protocol) {
                return null;
              } else {
                return "" + value + " is not a local URL";
              }
            } else {
              if (urlParts.protocol === "javascript:") {
                return "" + value + " has an invalid, javascript baring URL";
              } else {
                return null;
              }
            }
          }
          break;
        case type.substring(0, 6) !== "array:":
          if (!Array.isArray(value)) {
            return "'" + value + "' is not an array";
          } else {
            childType = type.substring(6);
            subError = null;
            for (_i = 0, _len = value.length; _i < _len; _i++) {
              subValue = value[_i];
              _ref3 = isExpectedType(subValue, childType), isChildValid = _ref3[0], childErr = _ref3[1];
              if (!isChildValid) {
                subError = "Invalid value of type '" + type + "': Subvalue " + childErr;
                break;
              }
            }
            return subError;
          }
          break;
        default:
          return "'" + type + "' is not a recognized data type";
      }
    })();
    if (error) {
      return [false, error];
    } else {
      return [true, null];
    }
  };

  module.exports = {
    areValidSettings: areValidSettings,
    checkTreeForDisallowedProperties: checkTreeForDisallowedProperties,
    isSafeCSSSelector: isSafeCSSSelector,
    isValidHtmlId: isValidHtmlId,
    isValidHtmlClass: isValidHtmlClass,
    validateNode: validateNode
  };

}).call(this);
