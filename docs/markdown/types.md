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
and discussed in greater detail below.  You can think of the settings property
on each instance as function parameters, or some way of providing
specific configuration to a particular instance of the type.

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
[event type](#event-types) child, [click](#clicks), indicating that some
behavior, omitted from the example, should occur when the user clicks on
the button.  Further, the button has some classes applied to it, for styling
purposes.

## Element Types
Element types are the basic building block of content within CDF. They describe
both the logical structure of the document and contain the actual text or media
references that comprise the document.  If you are familiar with HTML, Element
types are roughly analogous to the tags and text in an HTML document.  In
fact, the vast majority of the element types take their names from
HTML tags, and use the same parent-child relationship rules, as exist in
HTML 4.01.

The types of settings that element types accept also closely follow HTML.
With a few noted exceptions, all element types accept the following
settings, with semantics that generally mirror the semantics of the similarly
named attributes in HTML:

 * *id*: Used to uniquely label an element in the document, usually with the
   purpose of applying some styling rules in the presentation layer.  Takes
   a value of a string, matching the regular expression described in the
   **HTML IDs** section of the `validation patterns.html` document.
 * *class*: Used to identify an element so that styling rules can be applied
   to it in the presentation layer.  Takes an array of one more more strings,
   each matching the regular expression described in the **HTML Classes**
   section of the `validation patterns.html` document. 

Further more, CDF's element types also generally follow HTML's conventions
about what element types are valid children of what other element types.
For example, the `li` element type (used to describe an item in a list),
is a valid child of the `ul` element type (used to describe a list of items
where the order is not significant), but the `h1` element type (used to
describe the most significant heading in the document) is not a valid child
of the `img` element type (used to describe an image that should be rendered
inline in the document).  The HTML 4.01 parent-child rules can be found
[elsewhere on the web](http://www.cs.tut.fi/~jkorpela/html/nesting.html),
and so are not repeated here.

The element types included in CDF are described below, grouped together
by their general semantic purpose in CDF documents.

### Text Type
The `text` type is used to describe text that should be rendered inline in
the document.  This differs from HTML where there is no explicit text tag
or type, the author just adds the text to the document where needed.  CDF
uses an explicit text type to prevent any ambiguity on the part of the
document author for what is text and what is structure.

Instances of the `text` type are unique in several ways.  For one, they are
the only type in CDF that does not require an explicit labeling (ie `text`
instances do not require a *t* property).  They are also always leaf nodes
in the tree; no instance of any type can be a child of an instance of the
`text` type.

Finally, when the CDF document is parsed and rendered in the browser, the
`text` type's contents are "escaped", to ensure that the browser does not 
render any text as structure.  It does so using the
[html entities](https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references)
method.

Instances of the `text` type do not accept any settings.  They accept only
take only one property, *text*, which is unique to the text type.  The value of
this property is an arbitrary string that should be included in the document.

The below example shows several instances of the `text` type that, when combined
with instance instances of some [list type](#list-types) elements, depicts
a simple shopping list.

```json
{
  "t": "ul",
  "s": {
    "id": "shopping-list"
  },
  "c": [
    {
      "t": "li",
      "c": [
        {
          "text": "Milk"
        }
      ]
    },
    {
      "t": "li",
      "c": [
        {
          "text": "Sugar"
        }
      ]
    }
  ]
}
```

### Inline Types
Inline types are used to annotate pieces of text.  By convention they
do not designate sections of the document, but add semantic meaning to text
already in the document.  This is in contrast to the
[block types](#block-types), which are generally used to structure the
document, and not markup text.

Another way of conceptualizing this division, which is inherited from HTML,
is to think of inline types as those that should be flowed like text, from
left-to-right (or, right-to-left), while block types are those that should
be flowed top to bottom.  While this is not a hard-and-fast rule, since
any of these flow rules can be changed in the presentation layer, they
are hopefully useful in giving some intuition to the taxonomy. 

Most inline types do not accept any settings other than the previously
discussed *id* and *class* settings.  These types include:

  * `span`: Used to add a *class* or *id* to some text so that style rules
    can be applied to it in the presentation layer.
  * `em`: Used to add emphasis to a piece of text.  By convention this is
    represented with an italicised font when rendered in the browser.
  * `strong`: Used to add even more emphasis to a piece of text.  By convention 
    this is represented by a bold font in most browsers.
  * `small`: Used to remove emphasis from a piece of text.  By convention this
    is represented by a smaller font in most browsers.

In addition to the above types, CDF includes to other inline types, each of
which have their own settings and purpose. The `a` type is used to describe
links, either within the document or to other web pages.  Instances of the `a`
type accept three optional settings:

  * *href*: Describes a link to another part of the document, or to another
    webpage.  This setting accepts a string representing a valid HTTP URL.
  * *title*: Provides a description of where this link is pointing to.  Accepts
    a string.
  * *name*: Used for defining an end point for inner-document links (i.e. a link
    from one part of the page to another part of the page).

The final inline type is `img`, used to describe an image that should be
rendered inline in the document.  Instances of this type have one required
setting:

  * *src*: Describes where the images to be rendered in the document is
    located on the web.  Accepts a string describing a valid HTTP URL.

The `img` type also accepts several optional settings:

  * *alt*: Used to describe the image being included, either for text-only
    or vision impared clients.  Accepts an arbitrary string as input.
  * *width*: Describes the width of the image being displayed, so that it
    can be layed out in the document before the image has been fetched.
    Accepts a valid pixel string (ex 100 or 300px).
  * *height*: Describes the height of the image being displayed, so that it
    can be layed out in the document before the image has been fetched.
    Accepts a valid pixel string (ex 100 or 300px).

The below example shows how these types compose to represent a simple story.

```json
{
  "t": "p",
  "c": [
    {
      "text": "Yesterday, the strangest thing happened to me.  I woke up and
               then "
    },
    {
      "t": "strong",
      "c": [
        {
          "text": "bang!"
        }
      ]
    },
    {
      "text": "Something belew up in the back room and I was really scared. "
    },
    {
      "t": "a",
      "s": {
        "href": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "title": "Video of the scary thing I saw :)"
      },
      "c": [
        {
          "text": "Click here if you wanna see what I saw!"
        }
      ]
    }
  ]
}
```

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
