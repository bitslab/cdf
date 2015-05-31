(function() {
  "use strict";
  var argparse, args, cdfData, cdfParser, fs, inputCDF, inputFile, inputIsArray, inputIsObject, isSuccess, output, outputHandle, outputPath, parseError, parser, renderFunc, _ref;

  argparse = require("argparse");

  cdfParser = require("./render");

  fs = require("fs");

  parser = new argparse.ArgumentParser({
    version: 0.2,
    addHelp: true,
    description: "Command line tool to convert CDF documents and updates into HTML documents. If the root of the given file is a JSON encoded object / hash table, then the document is interpreted as a complete CDF document.  If the root is a JSON encoded array, the document is treated as a CDF update."
  });

  parser.addArgument(['-i', '--in'], {
    help: "Path to CDF document to convert.  If not provided, reads from STDIN."
  });

  parser.addArgument(['-o', '--out'], {
    help: "Path to write the resulting HTML+JS to.  If not provided, writes to STDOUT."
  });

  args = parser.parseArgs();

  inputFile = args["in"] || "/dev/stdin";

  outputPath = args.out || "/dev/stdout";

  outputHandle = fs.openSync(outputPath, "w");

  inputCDF = fs.readFileSync(inputFile, 'utf8');

  try {
    cdfData = JSON.parse(inputCDF);
  } catch (_error) {
    parseError = _error;
    console.error("Input is not a valid JSON document.  Received the following error when attempting to parse: " + parseError);
    process.exit(1);
  }

  inputIsArray = Array.isArray(cdfData);

  inputIsObject = (typeof cdfData === 'object') && (cdfData !== null);

  if (!inputIsArray && !inputIsObject) {
    console.error("The root of the given document is not an array or an object, and so is not valid CDF. CDF documents must be either an object (if it is a complete CDF document) or an array (if it is a CDF update).");
    process.exit(1);
  }

  renderFunc = inputIsArray ? cdfParser.renderUpdate : cdfParser.renderDocument;

  _ref = renderFunc(cdfData), isSuccess = _ref[0], output = _ref[1];

  if (!isSuccess) {
    console.error("There was an error attempting to parse the given CDF.\n " + output);
    process.exit(1);
  }

  fs.writeSync(outputHandle, output);

  process.exit(0);

}).call(this);
