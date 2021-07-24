#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Stop other crawler(s) if exist
pid=$(ps aux | grep '[n]ode index.js' | awk '{print $2}')

if [[ "$pid" == "" ]]; then
  echo "Crawler is not running."
else
  kill -9 $pid
  echo "$pid killed."
fi

exit 0