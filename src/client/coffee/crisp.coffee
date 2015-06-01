# Registry objects that type definitions register themselves in, so that
# we can define general code for routing between events -> behaviors ->
# deltas.
crisp = window.CRISP =
  behaviors: {}
  deltas: {}
  events: {}
  utils: {}


# Takes a <CSS selectors, CDF Delta instance> and returns a
# delta function that, when called, will query the document for nodes matching
# `cssSelector` add apply the defined delta.
crisp.utils.bindDelta = (cssSelector, deltaInst) ->
  deltaName = deltaInst.t
  deltaSettings = deltaInst.s
  deltaType = crisp.deltas[deltaName]

  if not deltaType
    throw "Unable to find definition for delta: '#{deltaName}'"

  ->
    jqueryWrappedDomNodes = jQuery cssSelector
    deltaType deltaSettings, jqueryWrappedDomNodes


# Many behaviors need to be registered, so that different instances of them
# can refer to the same behavior type (timers, states, etc.)
registerBehaviorInstance = (behaviorInst) ->
  behaviorName = behaviorInst.t
  behaviorSettings = behaviorInst.s

  behaviorType = crisp.behaviors[behaviorName]
  if behaviorType.register
    behaviorType.register behaviorSettings


# Responsible for triggering a single behavior's instance, based on
# a preexisting behavior definition in the global CRISP.behaviors
# registry object.
#
# Each call of this function is provided an object with
triggerBehaviorInstance = (behaviorInst) ->
  behaviorName = behaviorInst.t
  behaviorSettings = behaviorInst.s

  behaviorType = crisp.behaviors[behaviorName]

  # First check and make sure we can find a behavior definition for the
  # requested behavior type.  Again, the parser should have already ensured
  # this for us, so this check is mainly to make debugging easier.
  if not behaviorType
    throw "Unable to find definition for behavior: '#{behaviorName}'"

  behaviorType behaviorSettings


# Responsible for receiving an event definition from CDF, finding the
# relevant event definition, and preparing the arguments for the event
# instance.
#
# Each object provided to this function will have three keys
#   * "t" (string):  The name of the event that should be invoked here
#   * "s" (object):  Settings parameters, used for specifying when this
#                    event should trigger the attached behaviors
#                    (ex if the type is "click", the settings might
#                    define that this instance of the event should
#                    only happen on "right click").
#   * "b" (array):   An array of one or more behavior instance parameters.
#
# @param object eventInst
#   An object with three keys, as described above.
#
# @return null
bindEventInstances = (eventInst) ->
  eventName = eventInst.t
  eventSettings = eventInst.s
  childBehaviors = eventInst.b

  childBehaviors.forEach registerBehaviorInstance

  # First check and make sure that we can find an event definition for this
  # declared event type.  The parser should provide this for us,
  # so we're not going to try and gracefully handle this situation,
  # but just scream it as loudly as possible to make debugging easier.
  eventType = crisp.events[eventName]
  if not eventType
    throw "Unable to find definition for event '#{ eventName }'"

  # Check that we have an element defined for this event to trigger off
  # of.  If not, then something went wrong in the parser stage (since
  # the parser should be checking this for us) and so we should just
  # bail out.
  #
  # Some events do not have an element to bind against though (ex timers).
  # In this case, there will be no target id on the event instance, so
  # we skip this check and just pass along null for the target events.
  targetId = eventSettings.targetId
  if not targetId
    $targetElm = null
    cleanSettings = eventSettings
  else
    targetElm = document.getElementById targetId
    if not targetElm
      throw "Unable to find an element with ID '#{ targetId }' to bind an
             instance of the '#{ eventName }' event to."
    $targetElm = $ targetElm

    # Now just to make things slightly cleaner, and to make the api easier
    # to follow, prune out the settings that the event instances don't
    # have any business knowing about.
    cleanSettings = Object.create eventSettings
    delete cleanSettings.targetId

  # Finally, the event doesn't need to know about which behaviors it
  # is actually responsible for triggering, only when to trigger behaviors.
  # We abstract this away by not telling the event anything about
  # the behaviors it should trigger, but by just passing along
  # a function it should call. The function we pass along does
  # all the hard work of looking up behavior types,
  callbackFunc = ->
    childBehaviors.forEach triggerBehaviorInstance

  if eventType.register
    eventType.register $targetElm, cleanSettings, callbackFunc

  eventType $targetElm, cleanSettings, callbackFunc


jQuery ($) ->
  # Once we have the DOM fully loaded, we can start binding the events defined
  # in the CDF into actual CDF events, as implemented in client code.
  crisp.eventInstances.forEach bindEventInstances
