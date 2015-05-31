# Crisp Document Format

## Overview
This repo contains all the code needed to read CDF documents.  This includes
a **parser**, which takes CDF documents and generates an HTML+JS equivalent
document, **client libraries**, or javascript libraries that are intended
to be part of the browsers trusted base and which implement client side
functionality defined in a CDF document, and a **HTTP proxy**, which sits
between the CDF-speaking server and the client, and allows commodity browsers
to render CDF documents by translating them into HTML and javascript.

Each of these pieces are written in [coffeescript](http://coffeescript.org/),
intended to be run in [NodeJS](https://nodejs.org/).
[Grunt](http://gruntjs.com/) is used to manage building everything.


## Structure
The code and resources in this repo are organized as follows:

### Gruntfile.js
Build script, using the [Grunt](http://gruntjs.com) build system.  This is
analogous to a Make file, though uses node to implement the build process.
Build steps include compiling the coffeescript code into javascript and
using [compass](http://compass-style.org/) to build the
[SASS](http://sass-lang.com/) implemented styles in some of the demos.

### README.md
This very file you're reading right now.

### demos
Very simple examples of CDF applications.  They are not very useful, but
are intended to give examples of both how larger applications could be
structured, and demonstrate how each of three parts of the CDF system
work together.

### docs
Reference documents, most importantly the reference definition of the CDF
document format.

### LICENSE.txt
GPL3 license, which covers all of the code in the `/src` sub-directory. 

### package.json
The [NPM](https://www.npmjs.com/) package definition for all the code and
dependencies used in this project.  For those unfamiliar with how to use
this file, see the [NPM reference documentation](https://docs.npmjs.com/).

### src
The source code used for the project.  For each section, the original,
commented coffeescript is included in the `/src/<part>/coffee` subdirectory,
and the resulting, ready to run javascript in the `/src/<part>/js`
subdirectory. 

#### src/parser
Implementation of a CDF to HTML parser.  This code includes all code
needed to read in a javascript object representation of either a complete
CDF document, or a CDF update, and render back the needed HTML and javacript
for rendering and / or interpreting in a browser.

This code can be used directly with the included parser command line too.
You can use this with `node src/parser/js/parser.js --in <input file>`.
You can use the `--help` flag to see other available options.

#### src/proxy
Implementation of an HTTP proxy.  The proxy passes requests from the browser /
client to the destination, and then either converts the server's CDF response
into HTML and javascript to be rendered by the browser, or an error description
if the server's response is invalid CDF or HTTP response.  The only
exception is if the client is requesting a library that CDF implements, in
which case the proxy replies to the request itself.

The proxy is started by using the `src/proxy/js/proxy.js` script.  This
script accepts several arguments / flags, which are described with the
`--help` flag.

#### src/client
Client side javascript libraries that implement the interactive elements
of rendered HTML + JS documents.  They are served automatically by the
proxy.
 
