"use strict"


typeRegistery = require "./type-registery"
errors = require "./errors"


# Looks through an array of [isSuccess, error] values and returns the first
# error string encountered.  If no error is found (ie all tests were
# successful) returs null
#
# @param array testResults
#   An array of arrays of length two.  Each value in this array shoudl
#   be in the from [isSuccess, error] (ie [bool, null|string])
#
# @return string|null
#   The first error found in the results, or null if no errors.
firstErrorInResults = (testResults) ->
  testResults.reduce _firstErrorInResultsReduceFunc, null


# Helper function used in the `firstErrorInResults` function above.  Just
# defined here, instead of inline above, to avoid needing to create additional
# functions.
_firstErrorInResultsReduceFunc = (previousValue, currentValue) ->
  # If earlier in the reduce test we had an error string passed,
  # keep passing it along and ignore the rest of the values in the array
  if previousValue
    return previousValue

  # Otherwise, if everything has succeeded so far, but the current result
  # being considered is an error, pass the error string along
  [isSuccess, error] = currentValue
  if not isSuccess
    return error

  # Otherwise, if the current result being considered is a success, pass
  # null along to indicate everything has been a success so far.
  return null


# Wraps several common practices found throughout the code base.  Takes
# an array of items to test, and calls the func on each of them.  `Func`
# should return the common [isSuccess, error] pair for each test, describing
# if there was an error.
#
# @param array items
#   An array of values to validation with the `func` parameter
# @param function func
#   A function to call on all items in the `items` array.  This function
#   should return the common [isSuccess, error] result for each test
# @param object cdfNode
#   A cdf object in the cdf graph that should be responsible for any errors
#   generated.  Use only for generating error tracebacks if there is an error.
#
# @return array
#   An array of length two.
#
#   The first value is a boolean description of whether all values in
#   `items` passed the validation test.
#
#   If the first value is `true`, then the second value will be null.  If the
#   first value is `false` (indicating a validation error), the second value
#   is a string, with a graph trace, describing the first error encountered.
reduceWithError = (items, func, cdfNode) ->

  [isSuccess, error] = reduce items, func
  if not isSuccess
    return errors.generateErrorWithTrace error, cdfNode
  return [true, null]


# Calls a function on each item in an array until an error occurs or all
# items have been considered.  Takes optional additional arguments that
# can be provided on each call of func.
#
# @param array items
#   An array of items to provide as arguments to `func`
# @param function func
#   A function to call on each item in the `items` array.  The function should
#   return an array of length two, [isSuccess, error]
# @param mixed args...
#   Any additional arguments that are provided will be used as additional
#   arguments when calling func.  These arguments are positionally
#   after each argument in items.  For example, items = [1, 2, 3] and
#   args = "a" would result in func(1, "a"), func(2, "a") and func(3, "a").
#
# @return array
#   An array of length two.
#
#   The first value is a boolean description of whether calling func on
#   all values in `items` resulted in success cases.
#
#   If the first value is `true`, then the second value will be null.  If the
#   first value is `false` (indicating an error), the second value
#   is a string, the first error encountered.
reduce = (items, func, args...) ->

  wrappedReduceFun = (previousValue, currentValue) ->
    # Check to see if a previous result in this array of elements
    # being tested was false.  If so just return the error, instead
    # of performing any more tests (ie all tests are toxic)
    if Array.isArray(previousValue) and not previousValue[0]
      return previousValue

    (func currentValue, args...) or [true, null]

  (items.reduce wrappedReduceFun, null) or [true, null]


# Performs the given test on an element if the previous test was passed,
# otherwise just passes the previous error along.  Used for performing
# `reduce` style operations on arrays of elements.
#
# @param array cdfNodes
#   An array of CDF nodes to
# @param function testFunc
#   A function to call on the cdfNode.  This function should return
#   the standard (in this project) two item array result [isSuccess, err]
# @param array|undefined previousResult
#   Either the result of calling the same testFunc on a previous cdfNode
#   (in the same array that this node is a member of), or undefined
#   if this this the first element in the array.
#
# @return array
checkSubtreeUntilError = (cdfNode, testFunc) ->
  [isCurrentNodeValid, currentError] = testFunc cdfNode
  if not isCurrentNodeValid
    return [false, currentError]

  cdfType = typeRegistery.getTypeFromNode cdfNode
  children = cdfType.childNodes cdfNode

  checkFunc = (childNode) ->
    checkSubtreeUntilError childNode, testFunc

  reduce children, checkFunc


# Allows for an array of functions to be called against a single set of
# arguments, until either one of those functions returns an error response,
# or all functions have been called.
#
# @param array funcs
#   An array of functions to be called against the given arguments.  Each
#   function must return an array of length two (ie [isSuccess, error])
# @param ...
#   All additional arguments will be used as arguments for each of the
#   functions in the `funcs` array
#
# @return array
#   A array of length two.
#
#   The first value is a boolean description of whether all functions were
#   called successfully and returned non-error results.
#
#   If the first value is false, the second value is an error the first error
#   that was encountered.  Otherwise, the second value is false.
inverseReduce = (funcs, args...) ->
  wrappedFunc = (previousResult, currentFunc) ->
    if Array.isArray(previousResult) and not previousResult[0]
      return previousResult
    return currentFunc args...

  return (funcs.reduce wrappedFunc, null) or [true, null]


module.exports =
  checkSubtreeUntilError: checkSubtreeUntilError
  reduceWithError: reduceWithError
  firstErrorInResults: firstErrorInResults
  inverseReduce: inverseReduce
  reduce: reduce
