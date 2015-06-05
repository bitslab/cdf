"use strict"

util = require "util"


# Common function for throwing an exception for when a type has not implemented
# a method where it is expected to have one.
throwUnimplementedMethod = (cdfType, buildState) ->
  throw "Need Unimplemented function in '#{cdfType.name}' type"


# Functions to assist in error reporting and dealing with errors in trees

# Generates a string that shows a readable path from the root of the tree
# to the given element, to aid in debugging bad documents.
#
# These strings look something like this:
#
# root ->
#   intermediateNode ->
#     almostLeafNode ->
#       leafNode
#
# @param object cdfNode
#   A cdf object of any type
#
# @return string
#   Returns a formatted string describing the path from the root of the tree
#   to the given element.
generatePathFromRoot = (cdfNode) ->

  # First build up an array of all the nodes between the given element
  # and root of the tree (inclusive).
  nodes = []
  currentNode = cdfNode
  while currentNode
    nodes.push currentNode
    currentNode = currentNode._parent

  # Then pad out each node of the tree with one preceding tab for each
  # level deep they have in the tree.
  do nodes.reverse
  currentDepth = 0
  indentedNodeNames = for node in nodes
    nodeName = node.t

    # The version of V8 in node does not include String.prototype.repeat,
    # so we have to mock it up messy style here
    tabsForDepthCounter = currentDepth
    tabsForDepth = while tabsForDepthCounter-- > 0
      "\t"

    currentDepth += 1
    tabsForDepth.join("") + nodeName

  indentedNodeNames.join " ->\n"


# Returns more useful error output by adding a trace to the given error message.
#
# @param string error
#   A error message, describing what went wrong when attempting to validate
#   a given cdf element
# @param object cdfNode
#   A cdf element representing a node in the CDF tree
#
# @return array
#   Returns an array with length two.  The first value is always false (to
#   make the result returned from this function distinguishable from a success
#   condition).  The second value is a string describing the error.  This will
#   first be the provided error message, followed by a trace of where the
#   error occurred in the CDF tree.
generateErrorWithTrace = (error, cdfNode) ->
  treeTraceString = generatePathFromRoot cdfNode
  errorString = "#{ error }
  \n
  \nElement
  \n---------
  \n#{ util.inspect cdfNode }
  \n
  \nTrace
  \n----------
  \n#{ treeTraceString }"

  [false, errorString]


throwExceptionWithTrace = (exception, cdfNode) ->
  origExceptionDesc = do exception.toString
  [isError, wrappedErrorDesc] = generateErrorWithTrace origExceptionDesc, cdfNode
  throw new Error wrappedErrorDesc


module.exports =
  throwExceptionWithTrace: throwExceptionWithTrace
  generateErrorWithTrace: generateErrorWithTrace
  throwUnimplementedMethod: throwUnimplementedMethod
