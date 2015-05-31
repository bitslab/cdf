#!/usr/bin/env node
"use strict"

argparse = require "argparse"
cdfParser = require "./render"
fs = require "fs"

parser = new argparse.ArgumentParser
  version: 0.2
  addHelp: true
  description: "Command line tool to convert CDF documents and updates into
                HTML documents.
                
                If the root of the given file is a JSON encoded object / hash 
                table, then the document is interpreted as a complete CDF
                document.  If the root is a JSON encoded array, the document
                is treated as a CDF update."

parser.addArgument ['-i', '--in'],
  help: "Path to CDF document to convert.  If not provided, reads from STDIN."

parser.addArgument ['-o', '--out'],
  help: "Path to write the resulting HTML+JS to.  If not provided, writes to
         STDOUT."

args = do parser.parseArgs

# First figure out where we're reading from, either the given path or
# standard in if no path was provided.  Similarly, figure out where we're
# writing to and grab a handle to it, so that we can catch any permission
# errors, etc before we do any real work.
inputFile = args.in or "/dev/stdin"
outputPath = args.out or "/dev/stdout"
outputHandle = fs.openSync outputPath, "w"
inputCDF = fs.readFileSync inputFile, 'utf8'

# Next, attempt to convert the text we received into a javascript data
# structure.  If this is an object or an array, we'll continue, but
# an invalid parse, or a data structure with anything other than an array
# or object at the root is an error.
try
  cdfData = JSON.parse inputCDF
catch parseError
  console.error "Input is not a valid JSON document.  Received the following
                 error when attempting to parse: #{parseError}"
  process.exit 1

# Next, check and make sure that the read data structure meets the bare
# minimum of a CDF document (ie is either an array or an object).
inputIsArray = Array.isArray cdfData
inputIsObject = (typeof cdfData is 'object') and (cdfData isnt null)
if not inputIsArray and not inputIsObject
  console.error "The root of the given document is not an array or an object,
                 and so is not valid CDF. CDF documents must be either an
                 object (if it is a complete CDF document) or an array (if
                 it is a CDF update)."
  process.exit 1

# If the given document is an array, attempt to parse it as a CDF update.
# Otherwise, attempt to parse it as a CDF update.
renderFunc = if inputIsArray then cdfParser.renderUpdate else cdfParser.renderDocument
[isSuccess, output] = renderFunc cdfData
if not isSuccess
  console.error "There was an error attempting to parse the given CDF.\n
                #{output}"
  process.exit 1

# Otherwise, we have a successful parse, so output the document and
# give a success code
fs.writeSync outputHandle, output
process.exit 0
