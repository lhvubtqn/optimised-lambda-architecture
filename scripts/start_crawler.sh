#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Download NodeJS
if [ ! -d ./libs/node-v14.17.3-linux-x64 ]; then
  echo -e "\n⏳ Downloading node-v14.17.3-linux-x64"
  (cd ./libs && \
  curl -O https://nodejs.org/dist/v14.17.3/node-v14.17.3-linux-x64.tar.xz && \
  tar -xf node-v14.17.3-linux-x64.tar.xz && \
  rm node-v14.17.3-linux-x64.tar.xz)
fi

# Export environment
export NODE_HOME=$(pwd)/libs/node-v14.17.3-linux-x64
export PATH=$NODE_HOME/bin:$PATH

cd crawler
mkdir -p logs

$NODE_HOME/bin/npm install --unsafe-perm

export WAIT_TIME_MS_BEFORE_START=5000
export BOOTSTRAP_SERVERS=localhost:9092 
export TOPIC=buses-location 
export CRAWL_INTERVAL_MS=15000 

nohup $NODE_HOME/bin/node index.js > logs/crawler.logs 2> logs/crawler.logs &

pid=$(ps aux | grep '[n]ode index.js' | awk '{print $2}')

echo -e "\n🏭 Crawler started with pid: $pid."

exit 0