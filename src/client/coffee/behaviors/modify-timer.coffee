"use strict"

crisp = window.CRISP
behaviorRegistery = crisp.behaviors

behaviorRegistery["modify-timer"] = (settings) ->

  timerRegistery = crisp.events.timer.timerRegistery

  # Second check and make sure that the timer referenced by this behavior's
  # settings exists.
  timerId = settings.timerId
  timerObj = timerRegistery[timerId]
  if not timerObj
    throw "A modify-timer behavior instance tried to modify a timer with ID
          '#{timerId}' that does not corespond to an existing timer object."

  switch settings.action
    when "start" then do timerObj.start
    when "stop" then do timerObj.cancel
    when "reset" then do timerObj.cancelAndStart
