"use strict";

var replaceInTree = function (obj, from, to) {

  var keys;

  if (typeof obj !== "object") {
    return obj;
  }

  keys = Object.keys(obj);

  keys.forEach(function (aKey) {
    if (obj[aKey] === from) {
      obj[aKey] = to;
    } else {
      obj[aKey] = replaceInTree(obj[aKey], from, to);
    }
  });

  return obj;
};

var applyParams = function (obj, params) {

  Object.keys(params).forEach(function (from) {
    obj = replaceInTree(obj, "%" + from + "%", params[from]);
  });

  return obj;
};

module.exports.applyParams = applyParams;
