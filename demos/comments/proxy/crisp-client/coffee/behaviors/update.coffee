"use strict"

crisp = window.CRISP
behaviorRegistery = crisp.behaviors
deltasRegistry = crisp.deltas


# Takes a [css selector, delta inst] definition and applies it to the current
# document.
#
# @param array selectorDeltaPair
#   An array of length two.  The first element must be a string css selector.
#   The second element must be an object, generated by the CDF parser,
#   describing the settings for executing a delta.
applyDelta = (selectorDeltaPair) ->
  [cssSelector, deltaInst] = selectorDeltaPair
  domNodes = jQuery cssSelector
  deltaSettings = deltaInst.s
  deltaType = deltasRegistry[deltaInst.t]
  deltaType deltaSettings, domNodes


# This function takes a css selector and returns the value that
# should be sent to the server when doing a CDF update behavior.  This
# value will differ depending on the type of node returned for the CSS
# selector.
#
# For nodes of type "input", "select" and "textarea", the returned value
# is determined by the jQuery `val()` function.  For all other elements,
# the result of the jQuery .html() function is returned.
#
# @param string cssSelector
#   A valid css selector, accepted by the jQuery function
#
# @return array
#   An array of zero or more values, calculated as described above, for
#   sending to the server.
fetchValuesFromSelector = (cssSelector) ->
  nodes = jQuery cssSelector
  nodesAsArray = do nodes.toArray
  nodesAsArray.map (item) ->
    $item = jQuery item
    if $item.is "input, select, textarea"
      return do $item.val
    else
      return do $item.html


behaviorRegistery.update = (settings) ->
  # First, if there are any loading deltas to apply, apply them right away,
  # before we even start setting up the AJAX call
  if settings.loading
    settings.loading.forEach applyDelta


  params = {}
  if settings.values
    for [cssSelector, valueName] in settings.values
      params[valueName] = fetchValuesFromSelector cssSelector


  jQuery.ajax(
      url: settings.url
      method: settings.method
      data: params
      timeout: settings.timeout * 1000
      dataType: "json"
    )
    .done( (returnedDeltas) ->
      if settings.complete
        settings.complete.forEach applyDelta

      if not returnedDeltas
        return

      if not settings.targets
        return

      numDeltasToApply = Math.min settings.targets.length, returnedDeltas.length
      targetsToApply = settings.targets.slice 0, numDeltasToApply
      deltasToApply = returnedDeltas.slice 0, numDeltasToApply

      for cssSelector, i in targetsToApply
        delta = deltasToApply[i]
        applyDelta [cssSelector, delta]
    )
    .fail( ->
      if settings.error
        settings.error.forEach applyDelta
    )
