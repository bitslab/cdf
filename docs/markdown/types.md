# CDF Types

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

## 

## Element Types

```json
{
  "t": "div",
  "s": {
    "class": ["first-class", "second-class"]
  }
}
```

## Event Types

## Behavior Types

## Delta Types
