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

echo -e "\n🐳 Starting Storages"
docker-compose up -d --remove-orphans

CASSANDRA_CONTAINER=cassandra
echo -e "\n⏳ Waiting for Cassandra to be up and running"
while true
do
  if [ $(docker logs $CASSANDRA_CONTAINER 2>&1 | grep "Startup complete" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo -e "\n⏳ Creating Casandra schema..."
docker exec -it $CASSANDRA_CONTAINER cqlsh --username cassandra --password cassandra  -f /schema.cql

HDFS_CONTAINER=namenode
echo -e "\n⏳ Creating folders on HDFS & change permission..."
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /lambda-arch
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /lambda-arch/checkpoint
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /lambda-arch
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /lambda-arch/checkpoint

exit 0