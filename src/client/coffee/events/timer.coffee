"use strict"

# Defines all client side code needed to implement timers in the system.
# Each timer event instance in the CDF document is rendered by a timer
# object (created by the `makeTimer` function below) and entered / maintained
# in a registry, that associates the human readable name of the timer
# with the timer object.
#
# Storing timers in this way allows us to interact with them through the
# `timer` behavior.

crisp = window.CRISP
eventRegistery = crisp.events

timerRegistery = {}


# Creates a timer object, wrapping and calling the built in browser
# timer functions.  Each timer object has the following methods.
#
#  - cancel:  If the timer is still counting down to a future firing,
#             stops the timer from counting down.  If the timer is not
#             currently counting down, this method does nothing.
#  - start:   If the timer is not currently counting down to firing,
#             starts a new timer counting down.  If the timer is already
#             counting down, this does nothing.
#  - cancelAndStart:
#             Has the affect of calling cancel, and then start.
#
makeTimer = (timerSettings, cb) ->

  # The integer value returned by window.setTimeout or window.setInterval,
  # used so that we can stop the event if needed.
  timeoutId = null

  # Unpack some settings from the timer instance, to make the below code
  # easier to follow, and make it less necessary to keep paging back to
  # the parser details
  intervalInMs = timerSettings.ms
  timerName = timerSettings.timerId
  repeats = timerSettings.repeat

  cancelFunc = null
  startFunc = null
  if repeats
    cancelFunc = window.clearInterval
    startFunc = window.setInterval
  else
    cancelFunc = window.clearTimeout
    startFunc = window.setTimeout


  isCurrentlyRunning = ->
    return !! timeoutId

  executionFunc = ->
    if not repeats
      timeoutId = null
    do cb


  timerObject =

    cancel: ->
      if not do isCurrentlyRunning
        return

      cancelFunc timeoutId
      timeoutId = null

    start: ->
      if do isCurrentlyRunning
        return

      timeoutId = startFunc executionFunc, intervalInMs

    cancelAndStart: ->
      do timerObject.cancel
      do timerObject.start

  return timerObject


eventRegistery.timer = (elm, settings, cb) ->

  timerId = settings.timerId
  timerObject = timerRegistery[timerId]

  if settings.immediate
    do timerObject.start


eventRegistery.timer.register = (elm, settings, cb) ->

  timerId = settings.timerId
  timerRegistery[timerId] = makeTimer settings, cb


eventRegistery.timer.timerRegistery = timerRegistery
