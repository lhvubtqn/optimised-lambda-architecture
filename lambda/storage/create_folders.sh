#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                                  Storages                                ---"
echo "--------------------------------------------------------------------------------"

HDFS_CONTAINER=namenode

echo -e "\n⏳ Creating folders on HDFS & change permission..."
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /spark
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /spark/checkpoint
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /ola
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /ola/static_data
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /ola/historical_data
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /ola/aggregated_data
docker exec $HDFS_CONTAINER hdfs dfs -mkdir /temp

docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /spark
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /spark/checkpoint
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /ola
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /ola/static_data
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /ola/historical_data
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /ola/aggregated_data
docker exec $HDFS_CONTAINER hdfs dfs -chmod -R 777 /temp

exit 0
