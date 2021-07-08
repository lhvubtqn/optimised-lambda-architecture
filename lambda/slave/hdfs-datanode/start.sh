#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                                  Storages                                ---"
echo "--------------------------------------------------------------------------------"

./stop.sh

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

if [[ "$(docker volume ls | grep hdfs-datanode 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume hdfs-datanode\n"
  docker volume create hdfs-datanode
fi

echo -e "\n🐳 Starting Storages"
docker-compose up -d --remove-orphans

exit 0
