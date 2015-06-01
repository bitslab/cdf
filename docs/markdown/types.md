# CDF Types

## Outline

  * [Overview](#overview)
  * [Type Basics](#type-basics)
  * [Element Types](#element-types)
      * [Text Types](#text-type)
      * [Inline Types](#inline-types)
      * [Block Types](#block-types)
      * [List Types](#list-types)
      * [Table Types](#table-types)
      * [Form Types](#form-types)
      * [Document Structure Types](#document-structure-types)
  * [Event Types](#event-types)
      * [Interaction](#interaction)
           * [Clicks](#clicks)
           * [Mouse Movement](#mouse-movement)
           * [Keyboard](#keyboard)
           * [Appearance](#appearance)
      * [Timers](#timers)
  * [Behavior Types](#behavior-types)
      * [States](#states)
      * [Updates](#updates)
      * [Modify Timer](#modify-timer)
  * [Delta Types](#delta-types)
      * [Attributes](#attributes)
           * [Classes](#classes)
           * [Properties](#properties)
      * [Structural](#structural)
           * [Remove Subtree](#remove-subtree)
           * [Update Subtree](#update-subtree)
          

## Overview
CDF documents are trees formed from well defined types, which when combined
allow the author to express interactive web application descriptively,
rather than in imperative code executed in a client side event loop.

The CDF system consists of four categories of types. The role of each category
of type is described in detail in the following sections, but roughly the roles
break down as follows:

  * [Element types](#element-types) describe structure and text of the document.
  * [Event types](#event-types) describe input from the network or the user
    that should be reacted to somehow.
  * [Behavior types](#behavior-types) describe what should happen when an
    event has triggered.
  * [Delta types](#delta-types) describe changes to be applied to the document.

## Type Basics 

All types in CDF share certain common properties. All types define what types
they accept as children in the document tree. All types also define their
settings, the types of configuration parameters they accept to define specific
attributes of each type (e.g. the length of a timer, or a designation of a
particular structural instance so that the presentation layer can style it
accordingly). Finally, each type specifies how it should be rendered in the
client.

Instances of each type follow a similar pattern.  Each instance states
what type it is with a *t*–or **type**–property.  Each instance might also
specify some settings that affect the single instance with a *s*–or
**settings**–property.  The type and purpose of is unique to each type,
and discussed in greater detail below.

Instances also specify what elements in the tree are children of the current
instance.  The property used to define child elements depends on the 
instance's type, and the type of the children.  For example,
[Element types](#elment-types) can have both other elements as children, using
the *c*–**children**– property, and the instances of
[Event types](#event-types) as children, using the *e*–**events**–property.
[Event types](#event-types), on the other hand, only allow instances 
of [Behavior types](#behavior-types) as children, using the *b* property.

```json
{
  "t": "button",
  "s": {
    "class": ["btn", "btn-primary"]
  },
  "c": [
    {
      "t": "text",
      "text": "Click Me!"
    }
  ],
  "e": [
    {
      "t": "click",
      "b": [<omitted>]
    }
  ]
}
```

The above example shows a common example of how type instances are defined
in CDF documents.  It specifies an instance of a [button type](#button)
with two children, one [element type](#element-types) child, [text](#text),
which defines the text that should be rendered in the button, and a
[event type](#event-types) child, [click](#click), indicating that some
behaviors, omitted from the example, should occur when the user clicks on
the button.  Further, the button has some classes applied to it, for styling
purposes.

## Element Types

### Text Type
### Inline Types
### Block Types
### List Types
### Table Types
### Form Types
### Document Structure Types

## Event Types
### Interaction
#### Clicks
#### Mouse Movement
#### Keyboard
#### Appearance
### Timers

## Behavior Types
### States
### Updates
### Modify Timer

## Delta Types
### Attributes
#### Classes
#### Properties
### Structural
#### Remove Subtree
#### Update Subtree
