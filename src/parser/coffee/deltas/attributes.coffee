"use strict"

# This module describes deltas for modifying a subtree of the CDF document
# in place.  These deltas don't affect the structure of the tree (ex by
# removing "<p>" elements, or appending "<option>" elements to a "<select>"
# element), but adding / removing / changing properties to nodes that already
# exist in the tree.

validation = require "../utilities/validation"
baseDelta = require "./base"


# ======================= #
# ! Validation Functions  #
# ======================= #

validateAffectedProperties = (cdfNode, buildState) ->
  for key, value of cdfNode.c
    if key not in allowedProperties
      return [false, "'#{ key }' isn't a property that is valid to edit
                      with a 'properties' delta"]
  return [true, null]


# {
#   t: "classes",
#   s: {
#     action: "add",
#     change: [
#       "example-class", "another-class"
#     ]
#   }
# }
classes = ->
  base = do baseDelta.base
  base.name = "classes"
  base.clientScripts.push "deltas/attributes"

  base.defaultSettings.action = "add"
  base.validSettings.action = ["add", "remove"]

  base.requiredSettings.push "change"
  base.validSettings.change = "array:html class"

  return base


# For set property, we the "change" / payload we're describing changing
# are a series of HTML properties (value, disabled, etc).  Currently
# we limit this to a short allowed list of properties we feel safe manipulating,
# and all set properties must be strings (no more complex data types.)
#
# {
#   "t": "properties",
#   "s": {
#     change: {
#       "disabled": null,
#       "readonly": null,
#       "value": "edit me!
#     }
#   }
# }

# We validate these by checking that all the properties specified in the
# delta instance match one of the properties we allow to be modified.
allowedProperties = ["value", "disabled", "readonly", "selected", "clicked",
                     "src", "alt"]

properties = ->
  base = do baseDelta.base
  base.name = "properties"
  base.clientScripts.push "deltas/attributes"

  # The change property here describes some subset of the properties we
  # allow to be affected.
  base.defaultSettings.change = {}
  base.requiredSettings.push "change"
  base.validSettings.change = "object"

  base.validationFunctions.push validateAffectedProperties
  return base


module.exports =
  classes: classes
  properties: properties
