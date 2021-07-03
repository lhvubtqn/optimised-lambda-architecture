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

if [[ "$(docker volume ls | grep hdfs-namenode 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume hdfs-namenode\n"
  docker volume create hdfs-namenode
fi

if [[ "$(docker volume ls | grep hdfs-datanode 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume hdfs-datanode\n"
  docker volume create hdfs-datanode
fi

if [[ "$(docker volume ls | grep timescaledb-data 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume timescaledb-data\n"
  docker volume create timescaledb-data
fi

if [[ "$(docker volume ls | grep redis-data 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume redis-data\n"
  docker volume create redis-data
fi

echo -e "\n🐳 Starting Storages"
docker-compose up -d --remove-orphans

HDFS_CONTAINER=namenode
echo -e "\n⏳ Waiting for HDFS to be up and running"
while true
do
  if [ $(docker logs $HDFS_CONTAINER 2>&1 | grep "NameNode RPC up at" > /dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

exit 0
