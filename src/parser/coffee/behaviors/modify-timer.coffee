"use strict"

# This behavior allows for events to interact with timers that have been
# created previously, in the "timers" event module.
#
# Required Settings
#  - timerId (string):
#     The name of a timer event, specified elsewhere in the document.
#  - action (string, one of ["start", "stop", "reset"]):
#     * Selecting "start" will start the referenced timer if the timer is
#       currently *not* counting down.
#     * "stop" will stop the referenced timer if it *is* not counting down.
#     * "reset" will stop the timer (if it is currently counting down),
#       and then start it again.
errors = require "../utilities/errors"
validation = require "../utilities/validation"
baseBehavior = require "./base"
typeRegistry = require "../utilities/type-registry"


# Responsible for transforming the settings of the instance of the given type
# into an object of parameters that can be interpreted in the client's JS
modifyTimersSettings = (cdfNode, buildState) ->
  cdfType = typeRegistry.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

  behaviorSettings =
    t: cdfType.name
    s: cdfNode.s

  return behaviorSettings


modifyTimerBehavior = ->
  base = do baseBehavior.base
  base.name = "modify-timer"
  base.clientScripts.push "behaviors/modify-timer"

  base.requiredSettings.push "timerId"
  base.requiredSettings.push "action"

  base.validSettings =
    timerId: "string"
    action: ["start", "stop", "reset"]

  base.behaviorSettings = modifyTimersSettings

  return base


module.exports =
  "modify-timer": modifyTimerBehavior
