"use strict"


arrayTools = require "./array"
iter = require "./iteration"
errors = require "./errors"
buildTools = require "./build-tools"
typeRegistry = require "./type-registry"
url = require "url"


htmlIdPattern = /^[A-Za-z]+[A-Za-z0-9_:.-]*$/
htmlClassPattern = /^[A-Za-z_]+[A-Za-z0-9_-]*$/
validCSSSelectorPattern = /^[\d\s\w.#,-_>]*$/


# Attempts to validate a CDF node by making sure it has an advertised CDF
# type, that the CDF type can be looked up, and that the types validation
# checks pass against the node.
#
# @param object cdfNode
#   A CDF node, as defined by its corresponding type.
# @param object buildState
#   A document buildState object, as returned by
#   utilities.build-tools.makeBuildState
#
# @return array
#   Returns an array of length two.
#
#   The first value is a boolean description of whether the node is a valid
#   instance of a know CDF type.
#
#   If the first value is false, the second value is an error describing why
#   validation failed.  Otherwise, the second value is false.
validateNode = (cdfNode, buildState) ->

  # First check that the object we were passed looks at least like a javascript
  # object
  if !cdfNode or (typeof cdfNode isnt 'object')
    return [false, "Was passed a non-object, which is trivially not a valid
                    cdf node: '#{ cdfNode }'."]

  try
    cdfType = typeRegistry.getType cdfNode
  catch error
    return [false, error]

  # Now that we know the given object corresponds to a known CDF type,
  # run all of the validation functions for the type on the node
  valFuncs = cdfType.validationFunctions
  [isSuccess, error] = iter.inverseReduce valFuncs, cdfNode, buildState
  if not isSuccess
    return [false, error]

  # Finally, check and make sure that all the child nodes of the node
  # being validated are also valid.
  children = cdfType.childNodes cdfNode
  [areValid, error] = iter.reduce children, validateNode, buildState
  if not areValid
    return [false, error]

  [true, null]


# Sanity check the tree by making sure that the privileged (underscored)
# properties we add into the object graph are not there before we start
# processing the tree.  This is our guard against maliciously created documents
# that might try to trick the parser by entering their own values for these
# privileged (unchecked) properties in the tree.
#
# Basically, we just do a DFS of the tree and check for any underscored
# properties.  Once we safely determine that they're not in the tree, we
# can later be confident that the entered / underscored properties
# that appear in the tree are all safe.
#
# @param object cdfNode
#   A complete, but untrusted / unchecked cdfNode that is the root
#   of a (sub)tree of the document.
#
# @return array
#   An array of length two.
#
#   The first element is a bool, describing whether
#   the given CDF tree is free of underscore properties.
#
#   If so (ie the tree is safe for further parsing) the second value is null.
#   If the tree does not look safe, then the first value is false and the
#   second value is a string description of the error.
checkTreeForDisallowedProperties = (cdfNode) ->

  # First check and see if any of the properties on this node start with
  # an underscore.  Underscore properties are used by the parser
  # to internally tie parents and children together.  In order to ensure
  # that we are not processing a potentially malicious cdf document,
  # we check first to make sure that the author of the CDF document did
  # not include any underscore properties.
  propertyNames = Object.keys cdfNode
  invalidPropNames = propertyNames.filter (aPropertyName) ->
    return (aPropertyName[0] is "_") and (aPropertyName isnt "_parent")

  if invalidPropNames.length > 0
    error = "Found properties with invalid names:
             #{invalidPropNames.join ", "}"
    return errors.generateErrorWithTrace error, cdfNode

  # Otherwise, if there were no invalid properties on this node, check
  # to see if there are any child nodes on this object.  If so,
  # check them in the same way.
  #
  # Since we don't yet know that we've validated the entire tree (this function
  # may be getting called before any validation is occurring), we need to be
  # cautious and test for the possibility that there is an unknown / invalid
  # type in the tree.
  try
    cdfType = typeRegistry.getType cdfNode
  catch error
    return errors.generateErrorWithTrace error, cdfNode

  children = cdfType.childNodes cdfNode
  if not Array.isArray children
    error = "Received something other than a list when we expected to get an
             array of child nodes: #{children}"
    return errors.generateErrorWithTrace error, cdfNode
  iter.reduce children, checkTreeForDisallowedProperties


# Checks to see if the given string is a valid CSS selector.  This does
# not attempt to see if its a useful CSS selector (ie, it could be guaranteed)
# to match no results if its looking for a typo-typed tag like diiv),
# but at least one that cannot execute any kind of code.
#
# Not all css selectors are valid.  For convenience, we only allow a subset of
# valid CSS selectors:
#  * by tag, class or ID : div|.class|#id
#  * by child-status: div span
#  * by direct child-status: div > span
#  * chains of the above: div span, div div, ul li
#
#
# This check is very simple at the moment.  We just check to see if any
# characters other than the following are included in the given string:
#   \d\s\w.#>
#
# @param string selector
#   A string to check to make sure its safe to use as a CSS selector
#
# @return array
#   An array of length two.  The first value is a bool, describing if the
#   given string looks safe to use as CSS selector.  If the first value is
#   false, the second value will be a description of the error.  If the
#   first value is true, the second value will be null.
isSafeCSSSelector = (selector) ->
  if typeof selector isnt "string"
    return [false, "Given CSS selector is not of type 'string'"]
  if not selector.match validCSSSelectorPattern
    return [false, "CSS selector '#{ selector }' contains illegal characters"]
  return [true, null]


# Checks to see if the given string is a valid HTML id, and is safe
# and valid to use as the value of an HTML id="<something>" attribute.
#
# @param aString string
#   A string to check as a valid HTML id attribute
#
# @return array
#   An array of length two.  The first value will be a bool, describing
#   whether the given string was a valid HTML ID value.  If the first value
#   is false, the second value will be a description of the error.  If the
#   first value is true, the second value will be null.
isValidHtmlId = (aString) ->
  if typeof aString isnt "string"
    return [false, "Given HTML id '#{ aString }' is not of type 'string'"]
  if not aString.match htmlIdPattern
    return [false, "Given HTML id '#{ aString }' is not a valid HTML ID"]
  return [true, null]


# Checks to see if the given string is a valid HTML class, and is safe
# and valid to use as the value of an HTML class="<something>" attribute.
#
# @param aString string
#   A string to check as a valid HTML class value
#
# @return array
#   An array of length two.  The first value will be a bool, describing
#   whether the given string was a valid HTML class value.  If the first value
#   is false, the second value will be a description of the error.  If the
#   first value is true, the second value will be null.
isValidHtmlClass = (aString) ->
  if typeof aString isnt "string"
    return [false, "Given HTML class '#{ aString }' is not of type 'string'"]
  if not aString.match htmlClassPattern
    return [false, "Given HTML class '#{ aString }' is not a valid HTML class"]
  return [true, null]


# Performs some common settings validation by making sure that each of the
# values in the given settings object are each of an expected type.  Each
# of the values in the settingTypes should be one of the following types:
#  * "object":      An object (not generically, but a {} object)
#  * "int":         An integer
#  * "uint":        An unsigned int (ie an int >= 0)
#  * "bool"         true or false literal
#  * "string":      A javascript string
#  * "html class":  A string that is valid for an HTML class name
#  * "html id":     A string that is a valid html id string
#  * "css sel":     A string describing a css selector
#  * "local url":   A string describing a URL defining a resource on the same
#                   domain as the current document.
#  * "safe url":    A string describing a non-code baring URL (ie not
#                   javascript:)
#
# Additionally, values can be arrays of any of the above data types.  For
# example 'array:int' or 'array:html id' specifies that the array can only
# contain integer values, or valid HTML IDs, respectively.
#  * "array:<type>":       Should be a javascript array of the above types
#
# This function also checks that given settings object does not include any
# settings for which types are undefined (ie the set of keys for the settings
# object is a subset of the keys from the settingsTypes object).
#
# @param settings object
#   A javascript object, with keys being the behavior's settings, and the values
#   being the corresponding settings object (duh...)
# @param settingsDefs object
#   A javascript object that has all valid setting values for this behavior, and
#   the corresponding values, specified as strings of the type described above.
# @param string testType
#   Either 'settings' or 'properties', used just for creating useful
#   error messages about what we're validating.
#
# @return array
#   An array of two values, first being a boolean description of whether all the
#   given settings are valid, and the second being a description of the error
#   (if they're not all valid) or null (if they are all valid).
areValidSettings = (settings, settingsDefs, testType = "settings") ->

  # If we don't have any settings for this object, then all the present
  # settings are trivially valid
  if settings is undefined
    return [true, null]

  if testType not in ["settings", "properties"]
    throw "Invalid call to `validation.areValidSettings`.  Called with
          '#{testType}', but must be either 'settings' or
          'properties'"

  # Catch the simple case, where we expect an object of settings, but end
  # up getting something else.  Because of javascript "fun-ness" we need
  # to check this twice, first to make sure its not null, and then to make
  # sure its something that reports itself as an object
  if settings is null
    return [false, "'#{testType}' must be objects, not 'null'"]

  if typeof settings isnt "object"
    return [false, "'#{testType}' must be objects, not
                    '#{ typeof settings }'"]

  # Finally, check that each of the properties in the given object
  # matches the constraints of the validProperties / validSettings
  # definition.
  settingValuePairs = arrayTools.objectToArray settings
  return iter.reduce settingValuePairs, _isValidSetting, settingsDefs, testType


# Checks that a single setting pair (ie [setting name, setting value])
# is valid, given a definition of valid settings.
#
# @param array settingPair
#   An array of length two, with the first value being the name
#   of a setting, and the second value being the value for that setting
# @param object settingsDefs
#   A definition of what constraints there are for valid settings
#   on this type.  For example, setting this parameters to {a: "bool"}
#   specifies that the "a" setting must be a boolean value.
# @param string testType
#   Either the string "settings" or properties.  Used for creating more
#   useful error messages.
#
# @return array
#   An array of length two.
#
#   The first value is a boolean description of whether the given settings
#   are valid given the settings definition constraints.
#
#   If the given setting is valid, the second value will be false.  Otherwise,
#   the second value is a string describing the error.
_isValidSetting = (settingPair, settingsDefs, testType) ->

  [settingName, settingValue] = settingPair

  # When we're testing whether some properties are valid, we want to ignore
  # the "_parent" property, since this is inserted by the parser (and thus
  # does not need to be validated).  So it is trivially valid.
  if settingName in ["_parent"]
    return [true, null]

  if settingsDefs[settingName] is undefined
    return [false, "'#{testType}' param '#{ settingName }' is not specified
                    as a known / valid setting / property"]

  settingTypeRequirement = settingsDefs[settingName]
  return isExpectedType settingValue, settingTypeRequirement


# Checks to make sure that the given value is of the expected data type.
# valid types are:
#  * "object":      An object (not generically, but a {} object)
#  * "int":         An integer
#  * "uint":        An unsigned int (ie an int >= 0)
#  * "string":      A javascript string
#  * "bool"         true or false literal
#  * "array"        An array containing unchecked values
#  * "html class":  A string that is valid for an HTML class name
#  * "html id":     A string that is a valid html id string
#  * "css sel":     A string describing a css selector
#  * "local url":   A string describing a URL defining a resource on the same
#                   domain as the current document.
#  * "safe url":    A string describing a non-code baring URL (ie not
#                   javascript:)
#
# Additionally, values can be arrays of any of the above data types.  For
# example 'array:int' or 'array:html id' specifies that the array can only
# contain integer values, or valid HTML IDs, respectively.
#  * "array:<type>":       Should be a javascript array of the above types
#
# Finally, values can be arrays of valid types.  So if a value can be one
# of a finite number of options, type can be an array of explicit options,
# of which value must be a member.
#
# @param value mixed
#   Any value which type's should be tested
# @param type string|array
#   One of the above data type names (ex "int" or "array:int")
#
# @return array
#   An array of two values, first being a boolean description of whether all the
#   given settings are valid, and the second being a description of the error
#   (if they're not all valid) or null (if they are all valid).
isExpectedType = (value, type) ->

  error = switch
    # Finally, check the case where we have an explicit list of possible values
    # a setting can take on (specified by an array of values).
    when Array.isArray type
      if value not in type
        "'#{ value }' is not one of the valid values: '#{ type.join ", " }'"
      else
        null

    when type is "array"
      if not Array.isArray value
        "'#{ value }' is not an array"
      else
        null

    when type is "object"
      if typeof value is "object" and value isnt null
        null
      else
        "#{ value } is not an object"

    when type in ["int", "uint"]
      if typeof value isnt "number" or Math.floor value isnt value
        "'#{ value }' is not an integer"
      else if type is "uint" and value < 0
        "'#{ value }' is not a positive integer"
      else
        null

    when type is "string"
      if typeof value isnt "string"
        "'#{ value }' is not a string"
      else
        null

    when type is "bool"
      if value not in [true, false]
        "'#{ value }' is not a bool"
      else
        null

    when type is "html class"
      [isValidClass, classErr] = isValidHtmlClass value
      if isValidClass then null else classErr

    when type is "html id"
      [isValidId, idErr] = isValidHtmlId value
      if isValidId then null else idErr

    when type is "css sel"
      [isValidSelector, selErr] = isSafeCSSSelector value
      if isValidSelector then null else selErr

    when type in ["local url", "safe url"]
      if typeof type isnt "string"
        "#{ value } is not a local URL (because it isn't a string)"
      else
        urlParts = url.parse value, false, true
        if type is "local url"
          if not urlParts.host and not urlParts.protocol
            null
          else
            "#{ value } is not a local URL"
        else
          if urlParts.protocol is "javascript:"
            "#{ value } has an invalid, javascript baring URL"
          else
            null

    when type.substring(0, 6) is "array:"
      if not Array.isArray value
        "'#{ value }' is not an array"
      else
        # If we have an array of values, then check to make sure each of
        # them are valid too. First grab the child types of the array
        # off the definition name by just taking everything after "array:".
        # If this turns out to be garbage the recursive call of this step
        # will catch it.
        childType = type.substring 6

        subError = null
        # Now in order to do this recursively, we just create a new object
        for subValue in value
          [isChildValid, childErr] = isExpectedType subValue, childType
          if not isChildValid
            subError = "Invalid value of type '#{type}': Subvalue #{childErr}"
            break

        # Return the error from the sub array as the general array of the
        # switch statement, ie the result of validating the entire value.
        subError

    else
      "'#{ type }' is not a recognized data type"

  if error
    [false, error]
  else
    [true, null]


module.exports =
  areValidSettings: areValidSettings
  checkTreeForDisallowedProperties: checkTreeForDisallowedProperties
  isSafeCSSSelector: isSafeCSSSelector
  isValidHtmlId: isValidHtmlId
  isValidHtmlClass: isValidHtmlClass
  validateNode: validateNode
