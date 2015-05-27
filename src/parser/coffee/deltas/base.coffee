"use strict"

# Deltas are used to describe changes in the CDF tree.  They can be additions
# or removals of subtrees in the document, or changes to the existing tree
# structure (ie changing attributes in the tree).
#
# Deltas are expected to be small in purpose, so we expect using multiple
# deltas to perform several manipulations in the tree, rather than a
# large and complex one.
#
# "Deltas" follow the below pattern, in that they generally have a type ("t"),
# used to pair them to their type definition, and the change ("c") that should
# be applied to the tree.  Deltas often have a settings ("s") property, used
# for further tailoring the purpose of a more general type.
#
# For example, below is a valid instance of the "classes" delta, used for
# modifying the classes of elements in the CDF tree.  This definition
# specifies that the classes "class-one" and "class-two" should be added
# the CDF element.
#
# {
#   t: "classes",
#   s: {
#     "action": "add",
#     "change": ["class-one", "class-two"]
#   }
# }

typeRegistery = require "../utilities/type-registery"
baseType = require "../base"
clone = require "clone"


deltaSettings = (cdfNode, buildState) ->
  cdfType = typeRegistery.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

  settings =
    t: cdfNode.t
    s: clone cdfNode.s
  return settings


deltaBase = ->

  base = do baseType.base

  # Delta elements must describe the change that they want to make to the
  # document.  Note though that this will be very dependent on the delta
  # being described.  All delta types must describe their own purposes
  # for the change property.
  base.requiredProperties.push "s"
  base.requiredSettings.push "change"

  # Deltas have no structural content in the document (though they might
  # describe structural content).  Delta types shoudl implement the below
  # function to retun an object with the following two properties.
  #  - t (string): The name of the delta being described
  #  - s (object): Configuration settings needed to execute this delta
  #                in the client.
  #
  # Implementations of this function should also add any client scripts they
  # require to the provided buildState object
  base.deltaSettings = deltaSettings

  return base


module.exports =
  base: deltaBase
