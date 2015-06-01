(function() {
  "use strict";
  var checkSubtreeUntilError, errors, firstErrorInResults, inverseReduce, reduce, reduceWithError, typeRegistry, _firstErrorInResultsReduceFunc,
    __slice = [].slice;

  typeRegistry = require("./type-registry");

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
    cdfType = typeRegistry.getTypeFromNode(cdfNode);
    children = cdfType.childNodes(cdfNode);
    checkFunc = function(childNode) {
      return checkSubtreeUntilError(childNode, testFunc);
    };
    return reduce(children, checkFunc);
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

  module.exports = {
    checkSubtreeUntilError: checkSubtreeUntilError,
    reduceWithError: reduceWithError,
    firstErrorInResults: firstErrorInResults,
    inverseReduce: inverseReduce,
    reduce: reduce
  };

}).call(this);
