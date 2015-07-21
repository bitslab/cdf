"use strict"

# This module defines CDF events that match basic DOM events on HTML "flow"
# elements.  Things like click, etc

baseEvent = require "./base"


# ======================= #
# ! PreProcess Functions  #
# ======================= #

attachEventsToParents = (cdfNode, buildState) ->
  parentNode = cdfNode._parent
  if not parentNode
    return

  parentId = parentNode.s.id
  if not parentId
    return

  cdfNode.s.targetId = parentId


# ======================= #
# ! Validation Functions  #
# ======================= #

# Events define in this moudule need a targetId (ie an HTML ID) to specify
# with dom elements should be watched and responded to.  This function grabs
# the event's parent node (an element type), and assigns that parent item's
# html id to its on cdfNode.s.targetId property.
#
# If the parent event node does not have a target ID, this is an error
# condition.  However, we don't handle the error here (its ignored),
# we just refuse to assign anything to the targetId parameter, causing the
# validation to fail.
validateParentIds = (cdfNode, buildState) ->
  parentNode = cdfNode._parent
  if not parentNode or not parentNode.s.id
    [false, "Parent node does not an an html ID"]
  [true, null]


basicFlowEvent = (eventName) ->
  base = do baseEvent.base
  base.name = eventName

  base.validSettings.targetId = "string"
  base.requiredSettings.push "targetId"

  base.preprocessingFunctions.push attachEventsToParents
  base.validationFunctions.push validateParentIds
  return base


# For keyboard based events, we allow specifying a subset of keys we should
# listen to, and only reply to those.  If keyCode is undefined, then
# we respond to all events.
keyboardBasedEvent = (eventName) ->
  ->
    base = basicFlowEvent eventName
    base.clientScripts.push "events/basic"
    base.validSettings.keyCodes = "array:int"
    return base


mouseClickBased = (eventName) ->
  ->
    base = basicFlowEvent eventName
    base.clientScripts.push "events/basic"
    base.validSettings.button = ["left", "middle", "right"]
    return base


mouseMovementBased = (eventName) ->
  ->
    base = basicFlowEvent eventName
    base.clientScripts.push "events/basic"
    return base


appearanceBasedEvent = (eventName) ->
  ->
    base = do basicFlowEvent
    base.name = eventName
    base.clientScripts.push "contrib/jquery.appear"
    base.clientScripts.push "events/basic"
    return base


module.exports =
  click: mouseClickBased "click"
  doubleclick: mouseClickBased "doubleclick"
  disappear: appearanceBasedEvent "disappear"
  appear: appearanceBasedEvent "appear"
  mouseenter: mouseMovementBased "mouseenter"
  mouseleave: mouseMovementBased "mouseleave"
  mouseover: mouseMovementBased "mouseover"
  mouseout: mouseMovementBased "mouseout"
  keyup: keyboardBasedEvent "keyup"
  keydown: keyboardBasedEvent "keydown"
