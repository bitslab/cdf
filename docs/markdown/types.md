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
      "text": "Yesterday, the strangest thing happened to me.  I woke up and then "
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
Block types are generally used to distinguish sections of a document from
each other.  The term comes from HTML, which has a distinction between
inline elements and [block-level elements](https://developer.mozilla.org/en-US/docs/Web/HTML/Block-level_elements).
CDF's selection of block types are all taken from HTML.  All of these types
accept the previously described *id* and *class* settings.

  * `div`: A semantic-less container for text or other block level elements
    in the document.
  * `p`: A container element intended to contain only text and images, and
    not other structrual content.
  * `article`: A container meant to indicate that all the content and structure
    within relates to a single topic, concept or sub-document.
  * `header`: A container intended to store meta / annotating information
     about an acompaning `article`, such as a title, author, etc.
  * `footer`: A container intended to store other semantically relevant
    information relating to an accompaning `article`.  Often contains
    things like page numbers, copyright information, etc.
  * `h{1,6}`: Container for content headers.  Note that while headers
    imply a hiearchy of information, they are not nested, they are arbitrarly
    located in the document.
  * `aside`: A container intended to some content aside from the content it 
     is placed in, such as a sidebar.

#### Multimedia
There are two additional, multimedia handling types in CDF, `video` and
`audio`.  They, and the arguments they take, map closely onto the HTML5
`video` and `audio` types.  Both types require the below described `src`
setting.

  * *src*: Required, takes as argument an HTTP or HTTPS url describing where
    the related media can be found.

Finally, `video` and `audio` types accept the below optional settings.

  * *autoplay*: If set, takes the string "autoplay" to indicate that the
    refereneced media should start playing immediatly.
  * *controls*: If set, accepts the string "controls", indicating that the
    browser / client should provide the user with defaul multimedia controls
    (a start button, a stop button, etc.)
  * *loop*: If set, accepts the string "loop", indicating that when the player
    reaches the end of the referenced media, it should continue playing the
    media from the beginning.
  * *preload*: Accepts any of the following strings, "none", indicating that
    the client should not attempt to preload the media, and should request
    it only when the user wants to start playing it, "metadata", indicating
    that the client should fetch metadata about the media, such as the length,
    right away, but not the media itself, or "auto", indicating that the
    media should be fetched immediatly.


### List Types
CDF has types for expressing three types of lists, ordered, unordered, and
definition lists (again, mirrioring HTML).  

Ordered lists are indicated by a `ol` (ordered list) element, which accepts
zero or more children of type `li` (list item).  Unordered lists, or lists 
where the order of the children is not semantically meaningful, are indicated
by the `ul` (unordered list) element, also with zero or more `li` elements
as children.  `li` elements accept any inline types as children.

```json
{
  "t": "ul",
  "c": [
    {
      "t": "li",
      "c": [
        {"text": "First item"}
      ]
    },
    {
      "t": "li",
      "c": [
        {"text": "Second item"}
      ]
    }
  ]
}
```

Definition lists define pairs of names and descriptions of those names.
The parent element is of type `dl` (definition list) and takes pairs of child
elements, `dt` (definition term), which contains the element being defined,
and `dd` (definition definition), which contains the definition of the
element.

```json
{
  "t": "dl",
  "s": {
    "id": "simpsons-parents"
  },
  "c": [
    {
      "t": "dt",
      "c": [
        {"text": "Marge Simpson"}
      ]
    },
    {
      "t": "dd",
      "c": {
        {"text": "Mother of the family"}
      }
    },
    {
      "t": "dt",
      "c": [
        {"text": "Homer Simpson"}
      ]
    },
    {
      "t": "dd",
      "c": {
        {"text": "Father of the family"}
      }
    }
  ]
}
```


### Table Types
CDF includes elements to express table-structured data, where the rows, columns
and headings are semantically meaningful.  CDF's element types are again
taken directly from HTML, including nesting / child rules.

Tables begin with a `table` element.  The `table` type is a standard block
element, and so accepts the common element attributes (*class* and *id*).

The `table` type accepts one of three types of elements as children,
`thead`, indicating heading information for the table, `tfoot`, indicating
footer or summary information for the table, and `tbody`, the primary content
of the table.  These three types are intended to have different semantic
meaning to the client, but are treated identically by CDF (ie they all
accept the same types of child types, etc.).

`thead`, `tfoot` and `tbody` all accept zero or more instances of the `tr`
type (table row).  Each `tr` element then accepts zero or more 
`th` (table header) or `td` (table data) elements, depecting content
that should be displayed in a cell in the table.

`td` and `th` accept the below optional settings (note that the final setting 
in this section only applies the `th` elements).

  * *colspan*: Takes a positive integer describing the number of columns that
    this cell should span across in the table.  
  * *rowspan*: Takes a positive integer describing the number of rows that this 
    cell should span vertically in the table.
  * *scope*: (applies only to `th` elements) Takes one of four strings,
    describing how this heading value should be understood.  Valid values
    are "col" (cell is a header for a column, default), "row" (cell is a header
    for a row), "colgroup" (cell is a header for a group of columns) and
    "rowgroup" (cell is a header for a group of rows).


Below is a simple example of a table that describes two Simpsons characters.
```json
{
  "t": "table",
  "s": {
    "id": "simpsons-family"
  },
  "c": [
    {
      "t": "thead",
      "c": [
        {
          "t": "tr",
          "c": [
            {
              "t": "th",
              "c": [{"text": "First name"}]
            },
            {
              "t": "th",
              "c": [{"text": "Last name"}]
            },
            {
              "t": "th",
              "c": [{"text": "Role"}]
            }
          ]
        }
      ]
    },
    {
      "t": "tbody",
      "c": [
        {
          "t": "tr",
          "c": [
            {
              "t": "td",
              "c": [{"text": "Marge"}]
            },
            {
              "t": "td",
              "c": [{"text": "Simpson"}]
            },
            {
              "t": "td",
              "c": [{"text": "Mother"}]
            }
          ]
        },
        {
          "t": "tr",
          "c": [
            {
              "t": "td",
              "c": [{"text": "Homer"}]
            },
            {
              "t": "td",
              "c": [{"text": "Simpson"}]
            },
            {
              "t": "td",
              "c": [{"text": "Father"}]
            }
          ]
        }
      ]
    }
  ]
}
```


### Form Types
Form types allow authors to create form style applications in CDF, either for
submission in HTTP full page submissions, or composed with the `updates`
type to perform submission to the server that happen without needing to
referesh the page.

Forms that will be sent to the server with a page submission, and which the
client expects a new CDF document in return, begin with an instance of
the `form` type.  The `form` type accepts the following optional settings.

  * *name*: Takes a string and is used to name the set of values being
    submitted in the form submission.
  * *enctype*: Describes how the values in the form should be encoded when
    submitted to the server.  This setting accepts three strings,
    "application/x-www-form-urlencoded" (values should be url encoded when
    submitted, default), "multipart/form-data" (values should not be encoded,
    but submitted with section dividers, required when submitting files in
    the form) and "text/plain" (only the space character is encoded with "+",
    but values are otherwise unencoded).
  * *method*: Describes the HTTP method that should be used when submitting
    the form values to the server.  Valid values are "GET" (form values
    should be submitted in the URL as query parameters) and "POST" (form
    values should be included in the body of the HTTP request, required
    when dealing with file uploads).
  * *action*: Accepts a string describing a HTTP URL on the same domain
    that the current page is served from.  If not provided, the form values
    are submitted to the current URL.

The `form` type accepts any block or inline types as children, with the
exception of other `form` instance (ie `form` instances can not be nested).

The `form` type is generally invisble to the user.  Users instead interact
with `input`, `select`, `option`, `textarea` and `button` types (collectivly,
"input types").  When a `form` is submitted, the values contained in the
input types in the subtree of the document are sent.


#### Input Type
The `input` type generally describes a page element that takes input from
a user.  `input` instances are always leaves in the CDF document.  The `input`
type is used to depict a large nubmer of different inputs, determined by the
instance's *type* setting.

In most cases the *type* setting describes constrains that should be placed on
the input accepted from the user (ex must be numeric, or a date, etc.).
However, when *type* is "submit", the input is rendered in a special case,
as a button that, when clicked, submits the form.  

The `input` type accepts the following optional settings:

  * *name*: A string naming / label the value being submitted.
  * *type*: Accepts a string, describing the type of input expected.  Most
    clients will use this value to render a type-specific widget, to aid
    the user in inputting the requested value (ex a calendar widget
    for inputting dates).  Common values here are "text", "number", "date",
    "email", "file", "submit", "checkbox", "password", "radio" and "hidden" 
    (with the last case indicating that the value should not be visible to the
    user at all).
  * *value*: In most cases, this setting takes a string that should be used
    as the initial value for the form.  When the `input` has type
    "submit", this value is also used as the label of the button the user
    presses to submit this form.
  * *readonly*: Accepts either the empty string, indicating that this input
    is **not** readonly and that the user should be able to interact
    with it normally, or the string "readonly", indicating that the value
    **should** be submitted with the form, but **should not** be editable
    by her.
  * *disabled*: Accepts an optional string, either "" (empty string) or
    "disabled".  If the latter, the user will not be able to interact
    with this form element and the corresponding value will not be submitted
    to the server when the form is submitted.
  * *checked*: Only used when type is "checkbox" or "radio".  Accepts an
    optional string, either the empty string, indicating that this input
    should not be selected initially, or "checked", indicating that the input
    **should** be selected initially.
  * *placeholder*: Used when the type is "email", "text" or "number". Takes
    a string that should be presented to the user when the input is empty.
    This value **is not** sent to the server if the form is submitted.
  * *required*: Accepts either the string "required", indicating that the
    user should be prevented from submitting the form if this `input` instance
    does not have a value, or the empty string, indicating that the form
    can be submitted without this element having a value.


#### Mutually Exclusive Options
The `select` type describes a set of values a user can choose from.  The
`select` type is the container, and the individual options are defined with
`option` types.

The `select` type accepts the following optional settings:

  * *name*: A string naming / label the value being submitted.
  * *disabled*: Accepts an optional string, either "" (empty string) or
    "disabled".  If the latter, the user will not be able to interact
    with this form element and the corresponding value will not be submitted
    to the server when the form is submitted.

The `select` type accepts zero or more children of type `option`, each
describing a possible option.  The `option` type accepts the following
optional settings:

  * *value*: The string value that should be submitted to the server if this
    option is selected by the user.
  * *selected*: Accepts either the empty string, indicating that this option
    is not currently selected in the parent `select` instance, or "selected",
    indicating that this `option` instance should be selected by default.
    
`option` instances accept zero or more `text` instances as children, with the
text forming the user-visible label for this option.


#### Buttons
The `button` type is used to depict an element that users can click on to
produce some form related response.  They are generally presented identically
to an `input` instance with "type" submit.  They are commonly used for
AJAX applications (in CDF, using the `updates` event type), but can also
be used to submit forms.

The button type accepts the following optional settings.

  * *name*: A string naming / label the value being submitted.
  * *type*: Indicates the role of the button in the form.  Accepts the
    following strings, "button" (indicating that clicking the element **should
    not** submit the form), "submit" (indicating that clicking the element
    **should** submit the form) and "reset" (indicating that clicking
    the element should reset the values of the inputs in the form to their
    initial values).
  * *value*: The value that should be submitted to the server if this
    button has *type* "submit" and the user clicked on this button.
  * *readonly*: Accepts either the empty string, indicating that this input
    is **not** readonly and that the user should be able to interact
    with it normally, or the string "readonly", indicating that the value
    **should** be submitted with the form, but **should not** be editable
    by her.
  * *disabled*: Accepts an optional string, either "" (empty string) or
    "disabled".  If the latter, the user will not be able to interact
    with this form element and the corresponding value will not be submitted
    to the server when the form is submitted.

The `button` type accepts all inline types as children, with the exception
of the following types: `a`, `input`, `select`, `textarea`, `label` and `form`.


#### Textareas
The `textarea` type allows users to input a large amount of text, usually
depicted as a text input with multiple rows.  Unlike the other discussed
input types, the value that is submitted to the server by a `textarea`
instance is determined by the subtree of `text` nodes below the `textarea`
instance.

The `textarea` accepts the following optional settings:

  * *name*: A string naming the value controlled by the `textarea` instance
  * *readonly*: Accepts either the string "readonly", indicating that the
    instance is is not editable by the user, or the empty string (default)
    indicating that the user can interact with the `textarea` as normal.
  * *disabled*: Accepts an optional string, either "disabled", indicating that
    the field is not editable by the user **and** that the value should not
    be submitted to the user if the form is submitted, or an empty string.
  * *placeholder*: Takes a string, that should be presented to the user if the
    `textarea` contains no text.  This value is not sent to the server if the
    form is submitted.
  * *cols*: Takes a positive integer, indicating how wide the `textarea` widget
    should be, measured in characters.
  * *rows*: Takes a positive] integer, indicating how tall the `textarea`
    widget should be rendered, measured in characters.

The `textarea` type only accepts child elements of type `text`.  These
text nodes define the initial value of the field.


#### Labels
The `label` type provides a consistant and semantically meaningful way for
document authors to describe the purpose / role of form fields to users.
Clients use these labels to provide accessibility information for screen
readers, as well as typical text based labels.

`labels` are generally title of an input element.  This association between
the label an the form element is created in one of two ways, either:

  1. Nesting the input element being described by the `label` as a child of
     the label, or
  2. Using the *for* setting on the label to indicating the *id* of the
     form input being described.

The `label` type accepts the following option settings:

  * *for*: A string describing the *name* or *id* of the input element being
    described by the `label` instance.


#### Example Form
The below is a complete, if simple, example `form`, of the type that might
be used in a sign up form on a website.  On submission, this form would
send the text values in the input elements to the signup endpoint on the
server, which would then be expected to respond to that request with
a new CDF document.


```json
{
  "t": "form",
  "s": {
    "method": "POST",
    "action": "/signup",
    "name": "signup_form"
  },
  "c": [
    {
      "t": "label",
      "s": {
        "for": "first_name"
      },
      "c": [{"text": "First name"}]
    },
    {
      "t": "input",
      "s": {
        "type": "text",
        "placeholder": "Please enter your first name",
        "id": "first_name",
        "name": "first_name"
      }
    },
    {
      "t": "label",
      "s": {
        "for": "email"
      },
      "c": [{"text": "Email address"}]
    },
    {
      "t": "input",
      "s": {
        "type": "email",
        "required": "required",
        "placeholder": "account@example.org",
        "id": "email",
        "name": "email"
      }
    },
    {
      "t": "label",
      "c": [
        {
          "text": "Did you read the terms and conditions?"
        },
        {
          "t": "input",
          "s": {
            "type": "checkbox",
            "value": "1",
            "name": "terms",
            "id": "terms"
          }
        }
      ]
    },
    {
      "t": "input",
      "s": {
        "value": "Submit",
        "name": "submit",
        "type": "submit"
      }
    }
  ]
}
```

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
