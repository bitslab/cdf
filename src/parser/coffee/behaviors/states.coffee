"use strict"

# States are a way of describing changes in the CDF document that are
# self contained in the document, and don't require any further communication
# with the server.  Examples of common web patterns that are expressable as
# "states" are tabs, image carousels, etc.
#
# States are series of delta elements.  States can be advanced, retreated, etc.
#
# States can be shared between elements.  The first behavior in the tree
# referencing the state must include the state definition.


errors = require "../utilities/errors"
baseBehavior = require "./base"
typeRegistery = require "../utilities/type-registery"
validation = require "../utilities/validation"
deltaValidation = require "../deltas/validation"
iter = require "../utilities/iteration"
clone = require "clone"


# ======================= #
# ! Validation Functions  #
# ======================= #

# Check and make sure that that each state instance either defines a set of
# states, or refers to one that we've seen previously.
#
# Note that at this point, we've already verified that the stateId exists
# and is a string, so that check is not included below.
validateStateId  = (cdfNode, buildState) ->

  stateId = cdfNode.s.stateId
  stateDefinition = cdfNode.s.states
  stateIdRegistery = buildState.config "stateIds"

  # In order to be valid, one of the following must be true.  Either this
  # state instance has a state ID that we have not see before, and contains
  # a state definition, OR it has no state definition and but has a refernece
  # to a state definition seen previously.  If neither of these are true,
  # then there is an error (ie its a reference to a state that isn't declaired
  # prevously).

  isPrevouslySeenState = stateIdRegistery[stateId]

  # First, check the first case abve (that there is a unique state id and
  # no state definition).
  if stateDefinition and not isPrevouslySeenState

    # If this is the first time we've seen this state is, then include it
    # in the registery, so that other state definitions can refer to it.
    stateIdRegistery[stateId] = true
    return [true, null]

  # Next, check the second case, that there is not a state defined here,
  # but that it is a reference to a state that we've seen before.
  # This is also a valid state.
  if not stateDefinition and isPrevouslySeenState
    return [true, null]

  # Otherwise, if we haven't met either of the above cases, then there is
  # an error.  We just need to figure out what that error is so that
  # we can produce a useful error.  We can do these tests exaustivly, since
  # there are only two possible remaining cases...
  #
  # One, that there is a state definition AND a reference to a previously
  # seen state (an error because it creates ambiguity in which state which
  # id refers to).
  if stateDefinition and isPrevouslySeenState
    error = "Found a state definition AND a colliding state ID '#{stateId}'"
    return errors.generateErrorWithTrace error, cdfNode

  # Or, the only other remaining possible case is that we don't have a state
  # definition, and we do not have a reference to a previously seen state.
  # There is no test included here, since it is the only remaining possible
  # situation (given the above tests).
  error = "There is no state definition in this state behavior definition
           AND did not encounter any previous definition for a state with
           id '#{stateId}'"
  return errors.generateErrorWithTrace error, cdfNode


# If the "common" setting is present, check and make sure that it is an
# array of [css selector, delta] pairs
validateCommonSetting = (cdfNode, buildState) ->

  # Since the common setting is optional, if its not present it is trivially
  # valid.
  commonState = cdfNode.s.common
  if not commonState
    return [true, null]

  validationFunc = deltaValidation.validateCssSelectorDeltaPair
  return iter.reduceWithError commonState, validationFunc, cdfNode


# Check and make sure that all the css selectors used in defining whats
# affected by each set of deltas is a valid CSS selector
validateStates = (cdfNode, buildState) ->

  settings = cdfNode.s
  definedStates = settings.states
  if not definedStates
    return [true, null]

  # Here we're reducing a two dimensional array (an array of states, where
  # each state is an array of [css selector, delta] pairs).  So we first
  # create function that will reduce the deeper arrays, and then
  # use that resulting function to create a reducing function for validating
  # each state in the outer array of states.
  validationFunc = deltaValidation.validateCssSelectorDeltaPairs
  return iter.reduceWithError definedStates, validationFunc, cdfNode


# Check and make sure that if there is an `inital` setting provided
# with this instance, that there are also states defined here (ie that
# we're not in a reference to a set of states defined elsewhere).
validateInitialValueWithStates = (cdfNode, buildState) ->

  initialSetting = cdfNode.s.initial
  stateDefs = cdfNode.s.states
  if initialSetting and not stateDefs
    error = "Cannot have an `initial` setting value in a states behavior
             instance that does not include the states definition"
    return errors.generateErrorWithTrace error, cdfNode

  [true, null]


# Checks and makes sure that if an "initial" setting value is provided,
# that it is in the range of the number of states in a state set (ie
# if a state behavior has 3 states, this function checks that the initial
# value is either null, or [0, 2])
validateInitialRange = (cdfNode, buildState) ->

  initialSetting = cdfNode.s.initial

  # If there is not an initial value provided, then it trivially passes
  # this validation check
  if initialSetting is undefined
    return [true, null]

  # If we've gotten to this test, we've already ruled out the possibility
  # that there is an "initial" setting value, but no states defined here,
  # so we can continue assuming that there are states here (ie we're not
  # referencing a state behavior defined elsewhere).
  numStates = cdfNode.s.states.length
  if initialSetting < 0 or initialSetting >= numStates
    error = "Invaid 'initial' setting.  Must be in the range of [0,
             #{numStates}]"
    return errors.generateErrorWithTrace error, cdfNode

  [true, null]


# States can be labeled so that events from multiple elements in the document
# can all manipulate the same state in the document (ex one button could
# advance an image carousel, while a second button could cause it to retreat).
#
# Required Settings
#  * stateId (string):
#     A label for a states instance.  This must either be a reference
#     to a state behavior already declared previously in the document,
#     or a unique state id to refer to the state defined in this instance.
#
# Valid settings are for states are:
#  * wrap (bool, default: false):
#     Controls what should happen when each state has been advanced to the
#     end of its array of state changes.  If this is false, triggering the
#     event further on this element will have no effect.  If this is true,
#     trigger this event again will cause the element to take on the first
#     state change in the array.
#  * advance (bool, default: true):
#     Controls whether this behavior advances (true) or retreates (false)
#     the given state.
#  * index (int, default: null)
#     If provided, clicking this button will advance the state to the given
#     index, while walking through all the intermediate states.  If this
#     option is set, the `advance` property is ignored.
#  * states (array)
#     An array of arrays.  Each sub array is a collection of pairs, the first
#     value being a css selector, and the second being a delta definition
#     deltas that should be applied to the document when the document enters
#     the given state.  If this is empty, then the stateId must be populated
#     for settings, and it must refer to a stateId already seen in the document.
#  * common (array)
#     An array of [css selector, delta] pairs.  If provided, these states will
#     be applied before every state is applied.  These are, effectivly,
#     appened to the beginning of every state
#  * initial (int, optional)
#     If provided, this state will automatically be applied to the document
#     when the state is registered.  It only has an effect when its set in the
#     same behavior instance as the state definition (ie it cannot be set in
#     behavior instances that are refering to states defined elsewhere.)
#
# Below is a simple example of how tabs could be implemented using two states.
#
# {
#   t: "states",
#   s: {
#     stateId: "example state",
#     wrap: false
#     states: [
#       [
#         [
#           ".tab",
#           {
#             t: "classes",
#             s: {
#               action: "remove",
#               change: ["active"]
#             }
#           }
#         ],
#         [
#           ".tab.first",
#           {
#             t: "classes",
#             s: {
#               action: "add",
#               change: ["active"]
#             }
#           }
#         ]
#       ],
#       [
#         [
#           ".tab",
#           {
#             t: "classes",
#             s: {
#               action: "remove",
#               change: ["active"]
#             }
#           }
#         ],
#         [
#           ".tab.second",
#           {
#             t: "classes",
#             s: {
#               action: "add",
#               change: ["active"]
#             }
#           }
#         ]
#       ]
#     ]
#   }
# }
statesBehavior = ->
  base = do baseBehavior.base
  base.name = "states"

  base.clientScripts.push "behaviors/states"

  base.requiredSettings.push "stateId"

  base.defaultSettings =
    wrap: false
    advance: true

  base.validSettings =
    stateId: "string"
    common: "array:array"
    states: "array:array"
    index: "int"
    wrap: "bool"
    advance: "bool"
    initial: "int"

  base.childNodes = (cdfNode) ->
    children = []

    stateSets = cdfNode.s.states
    if stateSets and Array.isArray stateSets
      for state in stateSets
        for [cssSelector, deltaInst] in state
          children.push deltaInst

    commonState = cdfNode.s.common
    if commonState and Array.isArray commonState
        for [cssSelector, deltaInst] in commonState
          children.push deltaInst

    return children

  # For the states behavior, we want to give each delta the opportunity
  # to render its own script parameters.  So all we're doing below
  # is to replacing each definition of each state in the CDF tree
  # with whatever the delta instance wants to define itself as.
  base.behaviorSettings = (cdfNode, buildState) ->

    cdfType = typeRegistery.getType cdfNode
    cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

    settings = {}
    settings.t = cdfType.name
    settings.s = {}

    if cdfNode.s.common
      settings.s.common = for [cssSelector, deltaInst] in cdfNode.s.common
        deltaType = typeRegistery.getType deltaInst
        deltaSettings = deltaType.deltaSettings deltaInst, buildState
        [cssSelector, deltaSettings]

    if cdfNode.s.states
      settings.s.states = for state in cdfNode.s.states
        for [cssSelector, deltaInst] in state
          deltaType = typeRegistery.getType deltaInst
          deltaSettings = deltaType.deltaSettings deltaInst, buildState
          [cssSelector, deltaSettings]

    for key in ["stateId", "wrap", "advance", "index", "initial"]
      if cdfNode.s[key] isnt undefined
        settings.s[key] = cdfNode.s[key]

    return settings

  base.validationFunctions.push validateStateId
  base.validationFunctions.push validateCommonSetting
  base.validationFunctions.push validateStates
  base.validationFunctions.push validateInitialValueWithStates
  base.validationFunctions.push validateInitialRange

  return base


module.exports =
  states: statesBehavior
