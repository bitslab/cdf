Crispy Parser
===

Overview
---
This package is a [NPM](https://www.npmjs.org/) style package for parsing
YAML documents into HTML / JS.  It is all a (hacky) demo, toy kind of thing now,
so no efforts at security, etc. are in place.

Installation
---
Dependency management is handled in standard npm style:

    cd crispy-parser
    npm install

Description
---
This code takes specially formatted [YAML](http://yaml.org/) and produces
HTML and javascript needed for building an interactive modern web page.  By
taking the declarative YAML as input, we control the javascript that is
generated, and clients can run the generated web pages without needing to
trust arbitrary javascript.

CRISP documents must be valid YAML, and must be in sets of objects with the
following properties:

 * **type**:       The type of the element, from a defined set of supported
                   types. Types roughly correspond to HTML elements ("div", "p",
                   etc.), with the exception of *widgets* which are a predefined
                   set of sub elements.
 * **attributes**: Can be understood as meta data describing the object. These
                   values roughly correspond to  HTML attributes, such as
                   "class", "id", etc.
 * **text**:       The plain text content of the element, generally what
                   appears on the page, to the reader.
 * **children**:   A list of additional CRISP objects, that should be rendered
                   as children of the current object.

As mentioned above, the sole exception to this rule are **widgets**, which are
CRISP provided bundles of CRISP objects (and child objects), as well as some
client-side functionality.  Including a widget in the CRISP document will
include the necessary javascript for the widget to function as specified.

Widgets also have an additional **settings** property, where the document
creator can include various widget-specific settings.  For example, if a given
widget defines a user editable list, a supported setting here may allow the
document creator to define whether the list includes a "remove" button for
each element in the list.

Security Concerns
---
The current code does not enforce any security restraints, but only exposes
surface where those checks could easily be added.  Such checks might include:

 * Escaping all HTML that appears in the **text** property of a CRISP object,
   to remove the possibility of non-CRISP generated javascript from appearing
   in a document.
 * Having CRISP objects define a set of attributes they support.  For example,
   all elements support "id" and "class", but only "input" and its siblings
   ("button", "select", etc.) allow "value".
 * Defining what kinds of objects can be children of what other kinds of
   objects.  For example, HTML says that "p" elements can be children of "div"
   elements, but not vise versa.  CRISP could enforce this to further remove
   HTML parser ambiguities.
 * Ensuring that attribute values are valid strings per HTML requirements (ie
   you can't have a 'class' called `some-class" onclick="alert`, etc.)

Repo Description
---

`/lib`

Includes all the CRISP parser code.  This includes the code needed for parsing
CRISP documents, the client-side javascript libraries that end up being included
in the resulting page, etc.


`/lib/elements`

The currently implemented set of elements that can be included in a document.
Each file here is intended to implement an element type, such as "button" or
"input", etc.


`/lib/behaviors`

Descriptions of client side functionality. Each file here describes how
client side javascript / functionality should be rendered in the HTML document.


`/lib/widgets`

CRISP defined bundles of **elements** and **behaviors**.  These are the widgets
that are exposed in the YAML as `type: [widget-name]-widget`.


`/lib/renderers`

Javascript code that is responsible for taking a CRISP document (YAML) and
rendering it in a client-used format.  For example, `/lib/renderers/html5.js`
takes an object representing a crisp document and returns an HTML document
describing all the needed functionality.


`/crisp-client/*`

Code that is used by the browser when running a page generated from a CRISP
document.  As opposed to all the other javscript written in this project,
code in this directory is intended to be downloaded by the browser / client,
and run.  This is for widgets and similar functionality that needs javascript.
These are general instances of widgets, with instance specific options being
generated inline, in the document (stored in the client in
`window.CRISP.widgetInstaces`).


`/demo`

A simple webserver and YAML reader.  Running `node demo/sample.js` will do
the following:

 * Read the CRISP document in sample.yaml
 * Parse it into a series of CRISP objects
 * Render it to an HTML document, stored at index.html
 * Start a simple webserver (at localhost:8080) that serves up the generated
   html and javascript from the raw domain
 * Watches for changes to `sample.yaml`, a repeats the above steps on each
   change.
