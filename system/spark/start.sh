#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                               Spark Cluster                              ---"
echo "--------------------------------------------------------------------------------"

echo -e "\n🐳 Stopping Spark cluster"
docker-compose down -v --remove-orphans

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

echo -e "\n🐳 Starting Spark cluster"
docker-compose up -d --remove-orphans

exit 0