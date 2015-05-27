(function() {
  "use strict";
  var applyDefaultSettings, arrayTools, base, clone, commonChildNodes, commonRenderFunc, errors, iter, typeRegistery, validateProperties, validateSettings, validation, _setOneDefaultSetting, _validatePropertyExistsOnNode, _validateSettingExistsOnNode;

  arrayTools = require("./utilities/array");

  iter = require("./utilities/iteration");

  typeRegistery = require("./utilities/type-registery");

  validation = require("./utilities/validation");

  errors = require("./utilities/errors");

  clone = require("clone");

  _setOneDefaultSetting = function(currentSettings, aSettingPair) {
    var settingName, settingValue;
    settingName = aSettingPair[0], settingValue = aSettingPair[1];
    if (currentSettings[settingName] === void 0) {
      currentSettings[settingName] = settingValue;
    }
    return currentSettings;
  };

  applyDefaultSettings = function(cdfNode, buildState) {
    var cdfType, defaultSettingPairs, defaultSettings;
    cdfType = typeRegistery.getType(cdfNode);
    defaultSettings = cdfType.defaultSettings;
    if (!defaultSettings) {
      return;
    }
    if (!cdfNode.s) {
      cdfNode.s = clone(defaultSettings);
      return;
    }
    defaultSettingPairs = arrayTools.objectToArray(defaultSettings);
    return cdfNode.s = defaultSettingPairs.reduce(_setOneDefaultSetting, cdfNode.s);
  };

  _validatePropertyExistsOnNode = function(propertyName, cdfNode) {
    var error;
    if (cdfNode[propertyName] === void 0) {
      error = "Required property '" + propertyName + "' is missing from instance of '" + cdfNode.t + "'";
      return [false, error];
    }
    return [true, null];
  };

  validateProperties = function(cdfNode, buildState) {
    var cdfType, error, isSuccess, isValid, neededProps, settingsErr, validProperties, _ref, _ref1;
    cdfType = typeRegistery.getType(cdfNode);
    validProperties = cdfType.validProperties;
    _ref = validation.areValidSettings(cdfNode, validProperties, "properties"), isValid = _ref[0], settingsErr = _ref[1];
    if (!isValid) {
      return errors.generateErrorWithTrace(settingsErr, cdfNode);
    }
    neededProps = cdfType.requiredProperties;
    _ref1 = iter.reduce(neededProps, _validatePropertyExistsOnNode, cdfNode), isSuccess = _ref1[0], error = _ref1[1];
    if (!isSuccess) {
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return [true, null];
  };

  _validateSettingExistsOnNode = function(settingName, cdfNode) {
    var error;
    if (cdfNode.s[settingName] === void 0) {
      error = "Required setting '" + settingName + "' is missing from instance of '" + cdfNode.t + "'";
      return [false, error];
    }
    return [true, null];
  };

  validateSettings = function(cdfNode, buildState) {
    var cdfType, err, error, isValid, presentSettings, settingNames, validSettings, _ref, _ref1;
    cdfType = typeRegistery.getType(cdfNode);
    validSettings = cdfType.validSettings;
    presentSettings = cdfNode.s;
    _ref = validation.areValidSettings(presentSettings, validSettings), isValid = _ref[0], err = _ref[1];
    if (!isValid) {
      return errors.generateErrorWithTrace(err, cdfNode);
    }
    settingNames = cdfType.requiredSettings;
    _ref1 = iter.reduce(settingNames, _validateSettingExistsOnNode, cdfNode), isValid = _ref1[0], error = _ref1[1];
    if (!isValid) {
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return [true, null];
  };

  commonRenderFunc = function(cdfNode, buildState) {
    var cdfType, children;
    cdfType = typeRegistery.getType(cdfNode);
    cdfType.clientScripts.forEach(function(script) {
      return buildState.addScriptFile(script);
    });
    children = cdfType.childNodes(cdfNode);
    return children.map(function(childNode) {
      var childType;
      childType = typeRegistery.getType(childNode);
      return childType.render(childNode, buildState);
    });
  };

  commonChildNodes = function(cdfNode) {
    return [];
  };

  base = function() {
    return {
      name: null,
      mayAppearInSubtrees: false,
      clientScripts: [],
      preprocessingFunctions: [applyDefaultSettings],
      validationFunctions: [validateProperties, validateSettings],
      validProperties: {
        t: "string",
        s: "object"
      },
      requiredProperties: ["t"],
      defaultSettings: {},
      validSettings: {},
      requiredSettings: [],
      render: commonRenderFunc,
      childNodes: commonChildNodes
    };
  };

  module.exports = {
    base: base,
    render: commonRenderFunc
  };

}).call(this);
