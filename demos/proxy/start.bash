#!/bin/bash

node ./server.js &
node ./proxy/js/proxy.js &
