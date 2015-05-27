"use strict"

# The 'update' behavior sends a request to the server (on the same domain
# as served the containing CDF document), and then updating the page with
# [css selector, delta] pairs returned from the server.
#
# Required settings:
#   - url (string, local url):
#     A relative url, referring to a resource on the same page as served the
#     CDF document (ex: /endpoint or /endpoint.php are valid, but
#     http://example.org/endpoing is invalid)
#
# Optional settings:
#   - method (string, one of "GET", "POST", defaults to "GET"):
#     The HTTP verb to use when making the HTTP request to the server
#
#   - loading (array of [css selector, delta] pairs):
#     If provided, the given deltas will be applied to the document before
#     the HTTP request is made.
#
#   - error (array of [css selector, delta] pairs):
#     If provided, the given deltas will be applied to the document if the
#     HTTP request fails, or if the response from the server is not valid.
#
#   - complete (array of [css selector, delta] pairs):
#     If provided, the given deltas will be applied to the document if the
#     HTTP request succeeds.  These are applied before any deltas returned
#     from the server are applied (if any).
#
#   - targets (array of css selector strings):
#     CSS selectors to use when applying the deltas returned from the update
#     request.  If the length of this array differs from the number of deltas
#     returned, the smaller of the two will be used (so if there are more
#     css selectors than deltas returned, the additional CSS selectors
#     will be ignored.  If there are more deltas than css selectors in this
#     array, the additional returned deltas will be ignored).
#     Not setting this setting will, in effect, cause the returned value
#     of the web service request to be ignored.
#
#   - timeout (positive integer, default: 10):
#     The maximum number of seconds that can occur before the server responds
#     before the request is dropped and its considered an error.
#
#   - values: (array of [css selector, name] pairs):
#     If provided, controls which values will be sent to the server with
#     the request.  Each `name` must be a string matching the regex
#     /^[\d\w -\[\]]+$/ (ie only digits, ASCII letters, underscores, hyphens,
#     spaces, or square brackets).  Each coresponding css selector is used
#     to query the document for values to send to the server.
#
#     If the CSS selector matches an input, select, or textarea input,
#     the .val() of the element is returned.  Otherwise, the .text() is
#     returned (as described by the jQuery docs).
#
#     For example, given an html fragment:
#
#       <input class="std-input first-input" value="bart">
#       <input class="std-input second-input" value="lisa">
#
#     The arguments (".std-input", "names") would send to the server POST (or
#     GET) values: names=["bart", "lisa"].
#
#     The arguments (".first-input", "a_name") would send: a_name=["bart"]

baseBehavior = require "./base"
typeRegistery = require "../utilities/type-registery"
generalValidators = require "../utilities/validation"
deltaValidators = require "../deltas/validation"
iter = require "../utilities/iteration"
errors = require "../utilities/errors"


safeValueNamePattern = /^[\d\w \[\]-]+$/


# ============================== #
# ! Update validation functions  #
# ============================== #

# There are several places in the updates behavior where we want to validate
# a list [cssSelector, delta] pairs.  Instead of repeating ourselves, we
# just curry the functions we need.
#
# Note that both of these cases (loading, error) the values are optional.
_validateDeltaList = (settingsProperty) ->

  (cdfNode, buildState) ->
    # Since these delta lists are optional, having no delta values
    # (undefined) is trivially valid
    deltaPairs = cdfNode.s[settingsProperty]
    if not deltaPairs
      return [true, null]

    # The basic settings validation has already run, so we know that if there is
    # a delta list property, it is an array.  We now just need to check that the
    # array contains only valid [css selector, delta inst] pairs.
    [isValid, error] = deltaValidators.validateCssSelectorDeltaPairs deltaPairs
    if not isValid
      return errors.generateErrorWithTrace error, cdfNode
    return [true, null]


validateErrorDeltas = _validateDeltaList "error"
validateLoadingDeltas = _validateDeltaList "loading"
validateCompleteDeltas = _validateDeltaList "complete"


# Update behaviors can defined values to send to the server though pairs
# value names and css selectors.  Given an html document like
#
# <input class="std-input first-input" value="bart">
# <input class="std-input second-input" value="lisa">
#
# The arguments (".std-input", "names") would send to the server POST (or
# GET) values: names=["bart", "lisa"].
#
# The arguments (".first-input", "a_name") would send: a_name=["bart"]
#
# This validation checks that the given value name looks valid and not
# problematic (ie only contains digits, ASCII letters, spaces, hyphens, and
# square brackets), and that the given CSS selector is a safe, valid CSS
# selector
#
# @param array selecterNamePair
#   An array of length two.  The first value must be a css selector string.
#   The second value must be a value label (ie the name of the value
#   when sending it to the server).
#
# @return array
#   An array of length two.
#
#   The first value is a boolean description of whether both values are valid.
#
#   If the first value is `true`, then the second value will be null.  If the
#   first value is `false` (indicating a validation error), the second value
#   is a string, with a graph trace, describing the first error encountered.
validateCssSelectorValueNamePair = (selecterNamePair) ->

  if selecterNamePair.length isnt 2
    error = "The shape of the given [css selector, value name] pair is
             invalid.  Should be length two: '#{selecterNamePair}'."
    return [false, error]

  [cssSelector, valueName] = selecterNamePair

  # First check that the css selector looks safe.
  [isValid, error] = generalValidators.isSafeCSSSelector cssSelector
  if not isValid
    return [false, error]

  # Second, also check and make sure that the given name for the value to
  # send to the server is also valid and safe.
  if not valueName.match safeValueNamePattern
    error = "'#{ valueName }' is not a safe value name, does not match regex
             '#{ do safeValueNamePattern.toString }'"
    return [false, error]

  return [true, null]


# Validation function to check that if there are any values set to be
# sent with the update request, they all match the safety requirements
# of css selectors and form value names.
validateValuesSetting = (cdfNode, buildState) ->

  # Having values specified to be sent with the update request is optional,
  # so if no value is present, it is trivially valid
  values = cdfNode.s.values
  if not values
    return [true, null]

  # The standard settings validation will already have confirmed that, if there
  # is a values setting, it is an array.  We just now need to check that
  # the array contains [css selector, value name] pairs
  validationFunc = validateCssSelectorValueNamePair
  return iter.reduceWithError values, validationFunc, cdfNode


# ========================== #
# ! Update Render Functions  #
# ========================== #


updateBehaviorChildNodes = (cdfNode) ->
  children = []

  for settingKey in ["loading", "error", "complete"]
    if not cdfNode.s[settingKey] or not Array.isArray cdfNode.s[settingKey]
      continue

    for [cssSelector, deltaInst] in cdfNode.s[settingKey]
      children.push deltaInst

  return children


updateBehaviorSettings = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

  instSettings = cdfNode.s

  settings = {}
  settings.t = cdfType.name
  settings.s =
    url: instSettings.url
    method: instSettings.method
    timeout: instSettings.timeout

  if instSettings.values
    settings.s.values = instSettings.values

  if instSettings.targets
    settings.s.targets = instSettings.targets

  for settingKey in ["loading", "error", "complete"]
    deltas = instSettings[settingKey]
    if not deltas
      continue

    settings.s[settingKey] = for [cssSelector, deltaNode] in deltas
      deltaType = typeRegistery.getType deltaNode
      deltaSettings = deltaType.deltaSettings deltaNode, buildState
      [cssSelector, deltaSettings]

  return settings

# ============================= #
# ! Update Behavior Definition  #
# ============================= #


updateBehavior = ->
  base = do baseBehavior.base

  base.name = "update"
  base.clientScripts.push "behaviors/update"
  base.clientScripts.push "deltas/structure"
  base.clientScripts.push "deltas/attributes"

  base.requiredSettings.push "url"

  base.defaultSettings =
    method: "GET"
    timeout: 10

  base.validSettings =
    url: "local url"
    method: ["GET", "POST"]
    loading: "array:array"
    error: "array:array"
    complete: "array:array"
    targets: "array:css sel"
    timeout: "uint"
    values: "array:array"

  base.validationFunctions.push validateErrorDeltas
  base.validationFunctions.push validateLoadingDeltas
  base.validationFunctions.push validateCompleteDeltas
  base.validationFunctions.push validateValuesSetting

  base.behaviorSettings = updateBehaviorSettings
  base.childNodes = updateBehaviorChildNodes

  return base


module.exports =
  update: updateBehavior
