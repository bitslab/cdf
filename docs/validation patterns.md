# Validation Patterns

There are several places in the parser / CDF document format where we use
regular expressions for validation.  They are repeated and explained here
for convenience.  

Many of these patterns would probably be better suited with a full parser,
since some of the rules they are attempting to match are not fully-regular.
These patterns are just intended to be _good enough_ for a proof of concept,
while also ensuring safety.


## Posted Field Names
`/^[\d\w \[\]-]+$/`

The **updates** behavior allows the CDF author to define values that should
be sent to the server when requesting a document update.  CDF authors define
the names of each value they'd like to send (analogous to how inputs in
a form have names).  This pattern constrains the possible names that can be
used to name each sent value.

This pattern is used in `src/parser/coffee/behaviors/updates.coffee`.


## HTML Classes
`/^[A-Za-z\_]+[A-Za-z0-9_-]*$/`

In many places CDF authors can specify CSS classes.  For example, when
describing the markup of the document with the *classes* setting,
or in describing the changes an instance of the **classes** delta should make.

In order to safely generate HTML documents, and in order to prevent a malicious
CDF author from breaking out of the restraints CDF places on them, this pattern
is used to constrain the CSS classes they can use to a safe, easy to verify
subset of all valid CSS classes.

This pattern is used in `src/parser/coffee/utilities/validation.coffee`.


## HTML IDs
`/^[A-Za-z]+[A-Za-z0-9_:.-]*$/`

Similar to the *CSS Classes* pattern, there are several places where CDF
authors can specify an HTML ID, such as with the *id* setting for elements.

This pattern constrains the possible valid IDs CDF authors can use to prevent
CDF authors from adding unexpected javascript, HTML tags, or other elements
to the generated HTML documents.

This pattern is used in `src/parser/coffee/utilities/validation.coffee`.


## CSS Selector
`/^[\d\s\w.#,-_>]*$/`

There are several places where CDF authors can define CSS selectors, such
as defining what values should be extracted out of the document and sent
to the server when an **updates** behavior instance is triggered, or when
describing which elements of the document should be updated by a delta
instance.

This pattern is not intended to either match all valid CSS selectors, or
_only_ match CSS selectors.  It is instead intended to make sure a string
does not contain any HTML or self-executing javascript (such as a function
definition), while also matching at least enough valid CSS selectors to
be useful.

This pattern is used in `src/parser/coffee/utilities/validation.coffee`.
