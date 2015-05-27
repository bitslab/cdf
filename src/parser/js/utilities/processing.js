(function() {
  "use strict";
  var checkSubtreeUntilError, errors, firstErrorInResults, inverseReduce, makeBuildState, preprocessNode, reduce, reduceWithError, typeRegistery, _firstErrorInResultsReduceFunc,
    __slice = [].slice;

  typeRegistery = require("./type-registery");

  errors = require("./errors");

  firstErrorInResults = function(testResults) {
    return testResults.reduce(_firstErrorInResultsReduceFunc, null);
  };

  _firstErrorInResultsReduceFunc = function(previousValue, currentValue) {
    var error, isSuccess;
    if (previousValue) {
      return previousValue;
    }
    isSuccess = currentValue[0], error = currentValue[1];
    if (!isSuccess) {
      return error;
    }
    return null;
  };

  reduceWithError = function(items, func, cdfNode) {
    var error, isSuccess, _ref;
    _ref = reduce(items, func), isSuccess = _ref[0], error = _ref[1];
    if (!isSuccess) {
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    return [true, null];
  };

  reduce = function() {
    var args, func, items, wrappedReduceFun;
    items = arguments[0], func = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    wrappedReduceFun = function(previousValue, currentValue) {
      if (Array.isArray(previousValue) && !previousValue[0]) {
        return previousValue;
      }
      return (func.apply(null, [currentValue].concat(__slice.call(args)))) || [true, null];
    };
    return (items.reduce(wrappedReduceFun, null)) || [true, null];
  };

  checkSubtreeUntilError = function(cdfNode, testFunc) {
    var cdfType, checkFunc, children, currentError, isCurrentNodeValid, _ref;
    _ref = testFunc(cdfNode), isCurrentNodeValid = _ref[0], currentError = _ref[1];
    if (!isCurrentNodeValid) {
      return [false, currentError];
    }
    cdfType = typeRegistery.getTypeFromNode(cdfNode);
    children = cdfType.childNodes(cdfNode);
    checkFunc = function(childNode) {
      return checkSubtreeUntilError(childNode, testFunc);
    };
    return reduce(children(checkFunc));
  };

  inverseReduce = function() {
    var args, funcs, wrappedFunc;
    funcs = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    wrappedFunc = function(previousResult, currentFunc) {
      if (Array.isArray(previousResult) && !previousResult[0]) {
        return previousResult;
      }
      return currentFunc.apply(null, args);
    };
    return (funcs.reduce(wrappedFunc, null)) || [true, null];
  };

  preprocessNode = function(cdfNode, buildState) {
    var cdfType, children, func, preProcessFuncs, _i, _len;
    cdfType = typeRegistery.getType(cdfNode);
    preProcessFuncs = cdfType.preprocessingFunctions;
    for (_i = 0, _len = preProcessFuncs.length; _i < _len; _i++) {
      func = preProcessFuncs[_i];
      func(cdfNode, buildState);
    }
    children = cdfType.childNodes(cdfNode);
    return children.forEach(function(childNode) {
      return preprocessNode(childNode, buildState);
    });
  };

  makeBuildState = function() {
    var _config, _events, _html, _scripts;
    _html = [];
    _events = [];
    _scripts = {};
    _config = {};
    return {
      html: function() {
        return _html.join("\n");
      },
      addHtml: function(newHtml) {
        return _html.push(newHtml);
      },
      events: function() {
        return _events;
      },
      addEvent: function(newEvent) {
        return _events.push(newEvent);
      },
      scriptFiles: function() {
        return Object.keys(_scripts);
      },
      addScriptFile: function(newScriptFile) {
        return _scripts[newScriptFile] = true;
      },
      config: function(key) {
        if (!_config[key]) {
          _config[key] = {};
        }
        return _config[key];
      }
    };
  };

  module.exports = {
    preprocessNode: preprocessNode,
    makeBuildState: makeBuildState,
    checkSubtreeUntilError: checkSubtreeUntilError,
    reduceWithError: reduceWithError,
    firstErrorInResults: firstErrorInResults,
    inverseReduce: inverseReduce,
    reduce: reduce
  };

}).call(this);
