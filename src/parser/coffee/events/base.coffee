"use strict"

typeRegistery = require "../utilities/type-registery"
elementConstants = require "../elements/constants"
validators = require "../utilities/validation"
renderUtils = require "../utilities/render"
baseDefinition = require "../base"
clone = require 'clone'


eventChildNodes = (cdfNode) ->
  cdfNode.b


eventRender = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

  childBehaviors = cdfType.childNodes cdfNode
  behaviorSettings = childBehaviors.map (childNode) ->
    childType = typeRegistery.getType childNode
    childType.behaviorSettings childNode, buildState

  buildState.addEvent
    t: cdfType.name
    s: clone cdfNode.s
    b: behaviorSettings


# ================================ #
# ! Event Preprocessing Functions  #
# ================================ #

addParentConnectionToBehaviors = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  for bInst in cdfType.childNodes cdfNode
    bInst._parent = cdfNode


# ============================= #
# ! Event Validation Functions  #
# ============================= #

# Checks to make sure that each event instance has at least one behavior
# attached.  Otherwise, the event is triggering with nothing to do, which is
# either a waste or likely an error we can catch early by being strict on this.
#
# @param object cdfType
#   A reference to the type definition
# @param object cdfNode
#   A reference to the CDF event is an instance of the given type
# @param object buildState
#   A document builer, defined in document.coffee, that stores the HTML, event
#   definitions, and configuration settings needed to build the document.
#
# @return array
#   Returns an array of length two.  The first element is a bool describing
#   whether there is at least one behavior attached to this event.
#   If so, the second value will be null.  If its not valid,
#   the second value will be a string describing the error message.
validateHasBehaviors = (cdfNode, buildState) ->

  # Note that the `validateProperties` function from the base type
  # ensures that there is an array storing objects on this instance.
  # Here we just have to trivialy check that it has at least once object
  # in it.
  if not cdfNode.b or cdfNode.b.length is 0
    err = "'#{ cdfNode.t }' has no behaviors attached to it.  All events
    must have at least one associated behavior"
    return errors.generateErrorWithTrace err, cdfNode

  [true, null]


# Basic stub definition of an event, that actual event definitions should
# alter and pass along
baseEvent = ->

  base = do baseDefinition.base

  base.preprocessingFunctions.push addParentConnectionToBehaviors

  # An array of functions that should be called to validate this element.
  # Other event definitions can specify additional validation behavior by
  # pushing functions onto this list, or overwrite it completely.
  #
  # Each function in this array will be called with three arguments.
  #   - eventDef (object):  A reference to the event definition
  #   - eventInst (object): A reference to the CDF element is an instance of
  #                         the given event type
  #   - cdfDoc (object):    A reference to the entire CDF document that contains
  #                         the element and the element instance
  #
  # It should return an array with two elements in it, the first being whether
  # the validation was successful.  If "false", then the second item
  # should be a human readable error explanation.  Otherwise, should be null.
  base.validationFunctions.push validateHasBehaviors

  # In addition to the settings defined in the base type, event types
  # must include an array of at least one behavior
  base.validProperties.b = "array:object"
  base.requriedProperties = ["b"]

  base.childNodes = eventChildNodes

  base.render = eventRender

  return base


module.exports =
  base: baseEvent
