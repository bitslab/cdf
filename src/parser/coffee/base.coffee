"use strict"

# Common definitions for the four types of elements in CDF
#   - elements (the structure of the tree)
#   - events (triggers for interactivy)
#   - behaviors (definitions of that interactivity)
#   - deltas (definitions for changes in attributes in an existing tree)
#
# This is mostly an interface, since it defines very little behavior, and
# is mainly ment to establish a sane, standard API for the entire parsing
# system.

arrayTools = require "./utilities/array"
iter = require "./utilities/iteration"
typeRegistery = require "./utilities/type-registery"
validation = require "./utilities/validation"
errors = require "./utilities/errors"
clone = require "clone"


# ================================= #
# ! Common Preprocessing Functions  #
# ================================= #


# Takes a default setting definition (ie [name of setting, default value
# for setting]) and applies it the cdfNode if there is not already
# value for the setting.
#
# This function is used to fold all the default setting definitions
# into the given settings object.  So each call of the function
# applies the given default settings pair to the settings object,
# and then passes the settings object on.
#
# @param array aSettingPair
#   An array of length two.  The first value is the name of the setting,
#   and the second value is the default setting for that value
# @param object currentSettings
#   A settings object for a CDF node
_setOneDefaultSetting = (currentSettings, aSettingPair) ->
  [settingName, settingValue] = aSettingPair
  if currentSettings[settingName] is undefined
    currentSettings[settingName] = settingValue
  return currentSettings

# Populates the instance of a type with any default objects that are not
# defined in the object.  Note that this modifies the instance
# object.
applyDefaultSettings = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  defaultSettings = cdfType.defaultSettings
  if not defaultSettings
    return

  # If this object has default settings, but the instance has no settings,
  # then we're in the simple case of just assinging the default settings
  # to the instance
  if not cdfNode.s
    cdfNode.s = clone defaultSettings
    return

  # Otherwise, we populate the settings of the event's instance with each
  # default setting it is missing.

  # Convert the setting object into an array of arrays, so moving from
  # {a: 1, b: 2} -> [[a, 1], [b, 2]]
  defaultSettingPairs = arrayTools.objectToArray defaultSettings
  cdfNode.s = defaultSettingPairs.reduce _setOneDefaultSetting, cdfNode.s


# ============================== #
# ! Common Validation Functions  #
# ============================== #

# Checks that a given property exists on the provided CDF node.
#
# @param string propertyName
#   The name of a property that should exist on the given node.#
# @param object cdfNode
#   An instance of a CDF type
#
# @return array
#   An array of length two
#
#   The first element is a boolean description of whether the given
#   property exists on the node.
#
#   If the property does exist on the node, the second value is null.
#   If the proeprty does not exist, the second value is an string
#   describing the property that is missing.
_validatePropertyExistsOnNode = (propertyName, cdfNode) ->
  if cdfNode[propertyName] is undefined
    error = "Required property '#{ propertyName }' is missing from instance of
            '#{ cdfNode.t }'"
    return [false, error]
  [true, null]


# Checks to make sure that the given instance of a type only contains
# properties that are allowed by the type definition
validateProperties = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode

  # First, check and make sure that all the properties that are present
  # for this instance are valid for this type.
  validProperties = cdfType.validProperties
  [isValid, settingsErr] = validation.areValidSettings cdfNode, validProperties, "properties"
  if not isValid
    return errors.generateErrorWithTrace settingsErr, cdfNode

  # Second check that all the properties (ex "t" (type), "c" (children), etc)
  # that the type definition states are required for all instances are
  # present
  neededProps = cdfType.requiredProperties
  [isSuccess, error] = iter.reduce neededProps, _validatePropertyExistsOnNode, cdfNode
  if not isSuccess
    return errors.generateErrorWithTrace error, cdfNode

  [true, null]


# Checks that a given property exists on the provided CDF node.
#
# @param string settingName
#   The name of a property that should exist on the given node.#
# @param object cdfNode
#   An instance of a CDF type
#
# @return array
#   An array of length two
#
#   The first element is a boolean description of whether the given
#   property exists on the node.
#
#   If the property does exist on the node, the second value is null.
#   If the proeprty does not exist, the second value is an string
#   describing the property that is missing.
_validateSettingExistsOnNode = (settingName, cdfNode) ->
  if cdfNode.s[settingName] is undefined
    error = "Required setting '#{ settingName }' is missing from instance of
            '#{ cdfNode.t }'"
    return [false, error]
  [true, null]


# Checks to make sure that the given instance of a type has settings that
# are only of the types allowed by the type.  The settings are validated
# in two steps.
#
# First, check to make sure that all the given settings match the requirements
# of the type definition.
#
# Second, check and make sure that only all of the settings required by the
# type definition are present in the instance.
validateSettings = (cdfNode, buildState) ->

  cdfType = typeRegistery.getType cdfNode
  validSettings = cdfType.validSettings
  presentSettings = cdfNode.s

  [isValid, err] = validation.areValidSettings presentSettings, validSettings
  if not isValid
    return errors.generateErrorWithTrace err, cdfNode

  settingNames = cdfType.requiredSettings
  [isValid, error] = iter.reduce settingNames, _validateSettingExistsOnNode, cdfNode
  if not isValid
    return errors.generateErrorWithTrace error, cdfNode

  [true, null]


# Function should handle rendering the current node, along with
# all the child nodes in the CDF document.
#
# In the common case, we don't worry about anything in the current node
# and just render the children.
#
# @param object cdfType
#   A type definition object, describing the type of the current element
# @param object cdfNode
#   A node in the CDF tree, that is an instance of the given type definition
# @param object bulder
#   A document builer, defined in document.coffee, that stores the HTML,
#   event definitions, and configuration settings needed to build the
#   document.
commonRenderFunc = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script
  children = cdfType.childNodes cdfNode
  children.map (childNode) ->
    childType = typeRegistery.getType childNode
    childType.render childNode, buildState


# By default, we assume all types have no child nodes in the document.
# Different types must create their own version of this function to
# specify how their section of the tree should be traversed.
#
# In the common case we assume there are no child nodes on the current
# object.
#
# @param object cdfType
#   A type definition object, describing the type of the current element
# @param object cdfNode
#   A node in the CDF tree, that is an instance of the given type definition
#
# @return array
#   An array of zero or more pairs of objects.  Each value in the returned
#   array should be an array of two values, the first being a type definition
#   object, and the second an instance of that type.
commonChildNodes = (cdfNode) ->
  []


base = ->

  # A human readble name for this definition, used for generating error
  # messages and performing definition look ups based on the type
  # an object declares in a CDF type.
  name: null

  # Flag specifying whether it nodes of this type may appear in CDF subtrees
  # (ie deltas).
  mayAppearInSubtrees: false

  # An array of client scripts needed to render this type in the client.
  # This array should be complete (ie every required script), not
  # just the scripts needed in addition to those requested elsewhere.
  clientScripts: []

  # An array of functions that should be applied to each event object
  # before its validated and rendered. Each function in this list will
  # be called for each instance of the object in each tree.  This function
  # is allowed to modify the element in place. (no other functions can
  # do so).
  #
  # Each function in this array will be called with three arguments.
  #   - cdfType (object):  A reference to the type definition
  #   - cdfNode (object): A reference to the CDF element is an instance of
  #                        the given type
  #   - buildState (object):  A document builer, defined in document.coffee, that
  #                        stores the HTML, event definitions, and
  #                        configuration settings needed to build the
  #                        document.
  preprocessingFunctions: [applyDefaultSettings]

  # An array of functions that should be called to validate this element.
  # Other event definitions can specify additional validation behavior by
  # pushing functions onto this list, or overwrite it completely.
  #
  # Each function in this array will be called with three arguments.
  #   - cdfType (object):  A reference to the type definition
  #   - cdfNode (object): A reference to the CDF element is an instance of
  #                        the given type
  #   - buildState (object):  A document builer, defined in document.coffee, that
  #                        stores the HTML, event definitions, and
  #                        configuration settings needed to build the
  #                        document.
  #
  # It should return an array with two elements in it, the first being whether
  # the validation was successful.  If "false", then the second item
  # should be a human readable error explanation.  Otherwise, should be null.
  validationFunctions: [validateProperties, validateSettings]

  # A complete list of allowed properties for each instance of this type
  # in the CDF document.  This set of properites is validated in the same
  # way as the settings object
  validProperties:
    t: "string"       # The name of the type being implemented
    s: "object"       # Any configuration properites for this element

  # An array of properties that instances of this type must have.  This
  # array must contain a subset of a the keys of the `validProperties`
  # property for this type.
  requiredProperties: ["t"]

  # An object of default configuration options for type.
  # This might be something like a default time for a timer, or a default
  # mouse button definition for a "click" event.  Instances can override
  # these, but these will be applied where they are not in the instance.
  defaultSettings: {}

  # An object of optional settings for this type.  The purpose of a type
  # will differ between the purpose of each type ("element" types use settings
  # as attributes, "event" types use settings to configure how the setting
  # is called, such as what key board press is being watched for, etc.)
  validSettings: {}

  # An array of settings that instance of this type must have.  This must be
  # array containing a subset of the keys of the `validSettings` for this type.
  requiredSettings: []

  render: commonRenderFunc

  childNodes: commonChildNodes


module.exports =
  base: base
  render: commonRenderFunc
