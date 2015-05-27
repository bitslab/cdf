"use strict"

# CDF events relating to events being triggered when a certain amount of
# time has expired.

baseEvent = require "./base"


# ============================= #
# ! Timer Validation Functions  #
# ============================= #

# Check and make sure that the same timer Id doesn't appear in the document
# more than once.
validateTimerId = (cdfNode, buildState) ->
  timerIdRegistery = buildState.config "timerIdRegistery"

  timerId = cdfNode.s.timerId
  if timerIdRegistery[timerId]
    error = "Found duplicate timer ids: '#{ timerId }'"
    return [false, error]
  return [true, null]


# Timer is a general event for causing an behavior to trigger in the future.
#
# Required settings
#
#   - ms (int):         The amount of time, in the future, in miliseconds, that
#                       should pass before the attached behaviors trigger.
#   - timerId (string): A unique id for this timer.  Use so that the timer
#                       related behaviors can interact with this timer
#
# Optional settings
#   - repeat (bool):    If true, this event will repeat every `ms` seconds,
#                       instead of just once.
#   - immediate (bool): If true, the timer will start counting down as soon
#                       as the document loads.  Otherwise, the timer will
#                       wait until some behavior tells it to start.
#                       Defaults to `true`.
timer = ->
  base = do baseEvent.base
  base.name = "timer"

  base.clientScripts.push "events/timer"

  # Note that the timer event is different from most events (which need a
  # targetId to specify which element in the dom they bind against).  Since
  # timers are general, and not tied to a specific element, we need to
  # undo some of these boiler plate...
  base.requiredSettings = ["ms", "timerId"]

  base.defaultSettings.immediate = true

  base.validSettings.ms = "int"
  base.validSettings.repeat = "bool"
  base.validSettings.timerId = "string"
  base.validSettings.immediate = "bool"

  base.validationFunctions.push validateTimerId
  return base


module.exports.timer = timer
