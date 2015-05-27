"use strict"

# This module includes functions that are helpful for processing trees of
# cdf nodes into HTML+JS documents.

typeRegistery = require "./type-registery"
errors = require "./errors"


# Calls each of the preprocessing functions defined in a cdfType on a
# cdfNode (expected, but not required to be of the same type).
#
# @param object cdfNode
#   A reference to the CDF event is an instance of the given type
# @param object buildState
#   A document builer, defined in document.coffee, that stores the HTML, event
#   definitions, and configuration settings needed to build the document.  It
#   captures the state of the CDF tree being validated as this node is being
#   considered.
#
# @return array|null
#   "null" if everything preprocessed correctly.  Otherwise, will be a
#   standard [isSuccess, error] pair.
preprocessNode = (cdfNode, buildState) ->

  try
    cdfType = typeRegistery.getType cdfNode
  catch error
    return errors.generateErrorWithTrace error, cdfNode

  preProcessFuncs = cdfType.preprocessingFunctions
  func cdfNode, buildState for func in preProcessFuncs

  children = cdfType.childNodes cdfNode
  children.forEach (childNode) ->
    preprocessNode childNode, buildState


# An object used for tracking the state of rendering a CDF tree into HTML
# and javascript.  This is used for things like allowing each node in the
# tree to add any js libraries needed for the page in the client, as
# well as tracking encountered elements for validation purposes (ie seeing
# if a value that should be unique has been seen earlier in the document).
#
# @return object
#   A new build state object.
makeBuildState = ->
  _html = []
  _events = []
  _scripts = {}
  _config = {}


  # Returns the HTML needed to describe the parsed document so far.
  #
  # @return string
  #   A valid HTML fragment or document
  html: ->
    _html.join "\n"


  # Adds a new string to the build state.  Each HTML string is just
  # concatinated onto the existing HTML strings seen so far.
  #
  # @param string newHtml
  #   A new string to add to the HTML document being built.
  addHtml: (newHtml) ->
    _html.push newHtml


  # Returns all event definitions seen in the document so far.  Each event
  # definition is an object, describing the event type, and configuration
  # settings for that event, and the behaviors that should be executed when
  # this event fires.
  #
  # @return array
  #   An array of objects, each describing an event to bind in the HTML
  #   document.
  events: -> _events


  # Adds instance parameters for firing an event in the document.  Each
  # event should describe the event type (the "t" parameter), any settings
  # configuring how and when that event should be triggered (the "s" parameter),
  # and an array of behaviors that should be executed when this event
  # triggers.
  #
  # @param object newEvent
  #   An object describing an event should be triggered in the document,
  #   and what behaviors should be executed when the event triggers.
  addEvent: (newEvent) ->
    _events.push newEvent


  # Returns all javascript libraries that have been added to the build state
  # so far.  These are strings in the form of "behaviors/example", each
  # describing a library of javascript code that should be included in the
  # HTML document to carry out the events, behaviors and deltas
  # returned by the `events` method.
  #
  # @return array
  #   An array of strings, each naming a client side javascript library
  #   that should be included in the document.
  scriptFiles: -> Object.keys _scripts


  # Adds a reference to a client side javascript library that should
  # be referenced from the generated HTML in order to execute the
  # events added to the document so far.
  #
  # The references ommit the "/crisp-client/js/" prefix, and the ".js" suffix.
  # So to have the file "/crisp-client/js/events/appear.js" included in the
  # HTML document, use the argument "events/appear".
  #
  # @param string newScriptFile
  #   The name of a new javascript file to include in the HTML document.
  #   This should be in the form
  addScriptFile: (newScriptFile) ->
    _scripts[newScriptFile] = true


  # Returns an object managed by the types found in this CDF tree.  This allows
  # for other types of states to be pushed through the build process, and aids
  # in validation, such as keeping track of all the HTML ids that have been
  # observed in the document so far.
  #
  # @param string key
  #   A caller determined key for tracking an object used throughout the build
  #   process.
  #
  # @return object
  #   The previously seen object, if the given key has been called before,
  #   or otherwise a new object tied to this key.
  config: (key) ->
    if not _config[key]
      _config[key] = {}

    return _config[key]


module.exports =
  preprocessNode: preprocessNode
  makeBuildState: makeBuildState
