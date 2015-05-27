"use strict"

# Takes a javascript object and returns an array of arrays of length two.
#   ie {a: 1, b: 2} -> [[a, 1], [b, 2]]
#
# @param object anObject
#   A standard javascript object of unordered key -> value pairs
#
# @return array
#   An array of length-two arrays
objectToArray = (anObject) ->
  keyNames = Object.keys anObject
  keyNames.map (aKeyName) -> [aKeyName, anObject[aKeyName]]


remove = (anArray, elm) ->
  indexOfElm = anArray.indexOf elm
  switch indexOfElm
    when -1 then anArray[..]
    when 0 then anArray[1..]
    when anArray.length - 1 then anArray[0...]
    else anArray[0...indexOfElm].concat anArray[(indexOfElm + 1)..]


removeMany = (anArray, elements) ->
  elements.reduce remove, anArray


module.exports =
  objectToArray: objectToArray
  remove: remove
  removeMany: removeMany
