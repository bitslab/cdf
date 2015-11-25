"use strict"

# This module registers several events that map very easily onto DOM events,
# and thus probably don't need entire modules to themselves.  Things
# like mouse events (click, doubleclick) and keyboard events (keyup,
# keydown).

eventsRegistery = window.CRISP.events


appearPluginEvents = (eventName) ->
  eventsRegistery[eventName] = (elm, settings, cb) ->
    elm.on eventName, (event, newElements) ->
      do cb
      return false
    do elm.appear


addKeyboardEvent = (eventName) ->
  eventsRegistery[eventName] = (elm, settings, cb) ->
    elm.on eventName, (event) ->
      if settings.keyCodes and event.which not in settings.keyCodes
        return false
      do cb
      return false


addMouseClickEvent = (eventName) ->
  eventsRegistery[eventName] = (elm, settings, cb) ->

    mouseTarget = switch
      when settings.button is "left" then 1
      when settings.button is "middle" then 2
      when settings.button is "right" then 3
      else null

    elm.on eventName, (event) ->

      # Check to see if we should only be listening to events from
      # subset of mouse events
      if mouseTarget
        if event.which isnt mouseTarget
          return false
      do cb
      return false


addMouseMovementEvent = (eventName) ->
  eventsRegistery[eventName] = (elm, settings, cb) ->
    elm.on eventName, (event) ->
      do cb
      return false


["mouseenter", "mouseleave", "mouseover", "mouseout"].forEach addMouseMovementEvent
["keyup", "keydown"].forEach addKeyboardEvent
["click", "doubleclick"].forEach addMouseClickEvent
["appear", "disappear"].forEach appearPluginEvents
