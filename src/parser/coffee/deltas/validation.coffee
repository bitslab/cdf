"use strict"

# Common functions and routines for validating deltas, regardless of the
# type of delta.

baseValidation = require "../utilities/validation"
typeRegistery = require "../utilities/type-registery"
iter = require "../utilities/iteration"


# [css selector, delta] pairs are used in many places throughout the system.
# This function wraps validating both, returning a single answer to
# whether both are valid.
#
# @param array cssSelectorDeltaPair
#   An array of length two, with the first value being an CSS selector string,
#   and the second an object describing a valid delta instance
#
# @return array
#   An array of length two.
#
#   The first value is a bool, describing whether the pair of values are
#   valid.
#
#   If the first value is true (ie the values are valid), then the second
#   value is null.  Otherwise, the second value is a string describing the
#   error / why the values are invalid.
validateCssSelectorDeltaPair = (cssSelectorDeltaPair) ->
  if not Array.isArray cssSelectorDeltaPair
    return [false, "Given [css selector, delta] pair is not an array,
                    must be an array of length two.  Given value:
                    '#{cssSelectorDeltaPair}'."]


  if cssSelectorDeltaPair.length isnt 2
    return [false, "[css selector, delta] pair is not the right shape,
                    should be an array of length two:
                    '#{cssSelectorDeltaPair}'"]

  [cssSelector, deltaInst] = cssSelectorDeltaPair

  # The first, simplest check is to just make sure the CSS selector
  # matches our requirements for safety
  [isSafeSelector, error] = baseValidation.isSafeCSSSelector cssSelector
  if not isSafeSelector
    return [false, error]

  [isValid, error] = baseValidation.validateNode deltaInst
  if not isValid
    return [false, error]

  # Otherwise, everything looks good!
  return [true, null]


# Checks that an entire array of CSS selector / delta instances are valid.
# These are also used in many places in the CDF parser, such as in state
# definitions, in parsing the response returned from the update behavior,
# etc.
#
# @param array cssSelectorDeltaPairs
#   An array of [css selector, delta] pairs
#
# @return array
#   An array of length two.
#
#   The first value is a bool, describing whether all of the pairs in the
#   list are valid.
#
#   If the first value is true (ie the values are valid), then the second
#   value is null.  Otherwise, the second value is a string describing the
#   the first error encountered.
validateCssSelectorDeltaPairs = (cssSelectorDeltaPairs) ->
  iter.reduce cssSelectorDeltaPairs, validateCssSelectorDeltaPair


module.exports =
  validateCssSelectorDeltaPairs: validateCssSelectorDeltaPairs
  validateCssSelectorDeltaPair: validateCssSelectorDeltaPair
