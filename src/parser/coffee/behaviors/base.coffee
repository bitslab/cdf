"use strict"

# Behaviors allow CDF authors to add client side interactivity into their
# pages using a declaritive syntax.  Behaviors are are attached to
# events in CDF documents.
#
# Authors add a behavior to a CDF element by adding a "b" key
# to a CDF event element, with an array of one or more behavior
# definitions that should be attached to the event.


validators = require "../utilities/validation"
errors = require "../utilities/errors"
baseType = require "../base"
typeRegistery = require "../utilities/type-registery"


# ========================== #
# ! Preprocessing Functions  #
# ========================== #

# Note that no validation has happened so far, so we need to be extra
# timid in trying to build these connections.  Were not trying to describe
# errors or fix anything, just to only
attachDeltasToBehavior = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  for deltaInst in cdfType.childNodes cdfNode
    deltaInst._parent = cdfNode


baseBehavior = ->

  base = do baseType.base
  base.clientScripts = []

  # Add an additional pre-processing function to tie
  # any deltas contained in this behavior to the behavior instance (again),
  # to aid in debugging
  base.preprocessingFunctions.push attachDeltasToBehavior

  # Behaviors have no structural content in the document.  So all we need
  # to do to render behavior elements is to return the javascript / settings
  # information we need to trigger this behavior instance when the parent
  # event is fired.
  #
  # Implementations of this function should also add any client scripts they
  # require to the provided buildState object
  #
  # Each behavior should return an object with at least two properites,
  #  - t (string): The name of the behavior being described
  #  - s (object): Configuration settings needed to execute this behavior
  #                in the client.
  base.behaviorSettings = errors.throwUnimplementedMethod
  return base


module.exports =
  base: baseBehavior
