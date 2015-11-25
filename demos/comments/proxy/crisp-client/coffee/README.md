Client Side CDF Libraries
===

Of the four types of *things* in CDF (elements, events, behaviors, deltas),
the last three all require client-side code.  The purpose and API for
each is detailed below.

Events
---
Events describe when things should happen in the CDF document. They are
analgous in purpose to DOM events, though CDF does not support all DOM events
(and defines events that the DOM does not include).  All events in defined
in CDF require, at the least, some JS to tie the event DOM event together
with any behaviors that have been associated with that event in the CDF
element.

Each event client implementation is registered in the global
`window.CRISP.events` object.  Each event definition adds itself as follows:

`window.CRISP.events[<event name>] = function (elm, settings, cb) {};`

The parameters for each definition are as follows:

 - elm (object):        A jQuery wrapped DOM node that should have events bound
                        against it.
 - settings (object):   A javascript object, with zero or more keys set. These
                        key -> value pairs will be unique to the event
                        definition, though they will already be valdiated by
                        the CDF parser.
 - cb: (function):      A function that should be called when the event is
                        triggered.


Behaviors
---
Behaviors describe client side functionality in the CDF tree.  They are defined
to function independent of the event calling them.

Each client-side behavior implementation registers itself in the global
`window.CRISP.behaviors` object.  A behavior is "registered" by setting
its name as a key in this object, with the corresponding value being
a function taking the below parameters.

 - settings (object):   A behavior dependent set of configuration options.
                        The content of this object is defined by the
                        behavior's parser definition.

Deltas
---
Deltas describe a change of the document.  These changes can be changes in
the attributes of nodes in the tree, or changing the structure of the tree
itself (ie appending or removing subtrees from the tree).

Each client-side delta's behavior implementation registers itself in the
global `window.CRISP.deltas` object.  A delta is "registered" by setting
its name as a key in this global strucutre.  Each type is a function
that takes two arguments, the first an object defining configuration details
specific to that type, and the second being a CSS selector, describing which
nodes in the tree should be altered.

 - settings (object): An object describing paramters of how the delta should
                      be applied.  This will be unique to the type of delta
                      being called.  For example, a "classes" delta might use
                      these settings to configure whether we're adding or
                      removing classes, and the names fo the classes.
 - cssSel (string):   A css selector, used to query the DOM for elements
                      to modify.

Calling the type's function returns a function that takes no arguments.  
Calling this function queries the DOM using the given CSS selector, and applies
the delta to it.
