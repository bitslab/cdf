"use strict"

crisp = window.CRISP
behaviorRegistery = crisp.behaviors

# Each state is defined by a string, "state id".  This allows us to maintain
# state between different events calling into the same state.  This object
# tracks each state id (the key) with a "state set" object (ie whats
# returned from `makeStateSet`).
stateSetRegistery = {}

# All behaviors are defined by a single function which take a single settings
# object.  This object is stateless (ie it'll be identical each time this
# behavior is called).  Its the responsibility of the behavior to maintain
# any needed state.
behaviorRegistery.states = (settings) ->

  # First determine the state set we're referring to.  If we don't already
  # have one registered, we need to create one and store it for future
  # reference.
  stateId = settings.stateId
  if not stateId
    throw "Missing an identifier for state behavior"

  stateSetObject = stateSetRegistery[stateId]

  # Now that we know we have a correctly populated state set object,
  # we just need to respond to call the method on the state set object
  # that corresponds to the behavior's definition (basically this just
  # amounts to a big old switch statement).
  if settings.index isnt undefined and settings.index isnt null
    stateSetObject.setState settings.index
  else if settings.advance
    do stateSetObject.advance
  else
    do stateSetObject.retreat


behaviorRegistery.states.register = (settings) ->
  stateId = settings.stateId
  if not stateId
    throw "Missing an identifier for state behavior"

  # If this is the first time we see a state set with this Id, we need to
  # register it, so that it can be referenced elsewhere
  stateSetObject = stateSetRegistery[stateId]
  if stateSetObject
    return

  # First, extract the state and delta definitions from the CDF document.
  # If there are not any state definitions in the CDF document, and we
  # weren't able to find a previous state set definition, then we're
  # in an unfixable error condition...
  stateDefinitions = settings.states
  if not stateDefinitions
    throw "Reference to undefined state definition '#{stateId}'"

  isWrapping = settings.wrap
  commonState = settings.common
  boundStateSet = for aStateDef in stateDefinitions
    makeAState aStateDef
  stateSetRegistery[stateId] = makeStateSet boundStateSet, isWrapping, commonState

  if settings.initial isnt undefined
    stateSetRegistery[stateId].setState settings.initial


# A "State Set" is a collection of states.  The state set has knows which
# state in its collection of states is currently active.  It can be advanced
# and retreated, and can be arbitrarily advanced to a given state.
#
# @param array states
#   An array of states, functions returned from the below `makeAState`
#   function.
# @param bool wraps (default: false)
#   Whether the state should move from the last state to the first state
#   when advanced from the last state.  If false, nothing happens when advanced
#   from the last state.  This parameter similarly controls what happens when
#   the state set is retreated from the first index.
# @param array|null commonState (default: null)
#   An optional array of [css selector, delta] pairs that should be applied
#   at the beginning of every state application.
#
# @return object
#   Returns an argument with the following methods
#   - advance:        advances the set of states to the next state
#   - retreat:        retreats the set of states to the previous state
#   - advanceTo(int)  advances the set of states forward, calling all the
#                     states between the current state and the called one.
#
#                     If the given state index is less than the current state's
#                     index and `wraps` is false, then nothing is done.
#
#                     If the given state index is less than the current state's
#                     index is `wraps` if true, then the set of states is
#                     called to the max state, and then from the min state.
#
#                     If the given state index is greater than the total
#                     number of states in the state set, then an exception is
#                     thrown.
#  - retreatTo:(int)  Does the inverse of `advanceTo(int)`
#  - setState:(int)   Sets the state to be the state of the given index, without
#                     applying any intermediate steps.  If the given state
#                     index is greater than the number of states, then
#                     an exception is thrown.
makeStateSet = (states, wraps = false, commonState = null) ->

  commonStateFunc = if commonState then makeAState commonState else null

  numStates = states.length
  currentStateIndex = 0

  isLastState = ->
    currentStateIndex is numStates - 1

  isFirstState = ->
    currentStateIndex is 0

  advanceStateIndex = ->
    if do isLastState
      currentStateIndex = 0
    else
      currentStateIndex += 1

  retreatStateIndex = ->
    if do isFirstState
      currentStateIndex = numStates - 1
    else
      currentStateIndex -= 1

  applyCurrentState = ->
    if commonStateFunc
      do commonStateFunc
    do states[currentStateIndex]

  checkIsValidStateIndex = (aStateIndex, wrapDirection) ->
    if typeof aStateIndex isnt "number"
      throw "Invalid requested state index.  Not a number: '#{aStateIndex}'"

    if Math.floor aStateIndex isnt aStateIndex
      throw "Invalid requested state index.  Not an integer: '#{aStateIndex}'"

    if aStateIndex < 0
      throw "Invalid requested state index.  Less than zero: '#{aStateIndex}'"

    if aStateIndex >= numStates
      throw "Invalid requested state index '#{aStateIndex}'.  Larger than
             number of states: '#{numStates}'"

    # If we've been passed noting for the wrapDirection argument,
    # it means to ignore any tests related to whether we're traveling in the
    # right direction, etc.
    if !wrapDirection
      return true

    isAdvancing = switch
      when wrapDirection is "advancing" then true
      when wrapDirection is "retreating" then false
      else null

    if isAdvancing and aStateIndex < currentStateIndex and not wraps
      throw "Invalid requested state index.  Requested index
            '#{aStateIndex}' is before the current state index
            '#{currentStateIndex}' and we're not configured to wrap"

    # This equality is only done to make the below test easier to reason
    # about / read...
    isRetreating = not isAdvancing

    if isRetreating and aStateIndex > currentStateIndex and not wraps
      throw "Invalid requested state index.  Requested index
            '#{aStateIndex}' is after the current state index
            '#{currentStateIndex}' and we're not configured to wrap"

    return true


  stateSetObject =
    advance: ->
      # If we're at the last state, and we're not wrapping, then
      # there is nothing to do.
      if do isLastState and not wraps
        return

      do advanceStateIndex
      do applyCurrentState

    retreat: ->
      if do isFirstState and not wraps
        return

      do retreatStateIndex
      do applyCurrentState

    advanceTo: (newStateIndex) ->
      checkIsValidStateIndex newStateIndex, "advancing"
      while currentStateIndex isnt newStateIndex
        do stateSetObject.advance

    retreatTo: (newStateIndex) ->
      checkIsValidStateIndex newStateIndex, "retreating"
      while currentStateIndex isnt newStateIndex
        do stateSetObject.retreat

    setState: (newStateIndex) ->
      checkIsValidStateIndex newStateIndex
      currentStateIndex = newStateIndex
      do applyCurrentState

  return stateSetObject


# A state is a function that, when called, applies a set of deltas to the
# current document / DOM.
makeAState = (aStateDef) ->
  boundFunctions = []
  for [cssSelector, deltaInst] in aStateDef
    boundFunctions.push crisp.utils.bindDelta cssSelector, deltaInst
  return ->
    do func for func in boundFunctions
