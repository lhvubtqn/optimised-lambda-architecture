#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                                    HDFS                                  ---"
echo "--------------------------------------------------------------------------------"

./stop.sh

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

echo -e "\n🐳 Starting HDFS"
docker-compose up -d --remove-orphans

sleep 5

HDFS_CONTAINER=namenode
echo -e "\n⏳ Creating folders on HDFS & change permission..."
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /lambda-arch
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /lambda-arch/checkpoint
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /lambda-arch
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /lambda-arch/checkpoint

exit 0