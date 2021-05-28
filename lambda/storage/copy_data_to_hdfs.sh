#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                                  Storages                                ---"
echo "--------------------------------------------------------------------------------"

HDFS_CONTAINER=namenode

echo -e "\n⏳ Copying data folders to HDFS..."
docker exec $HDFS_CONTAINER hdfs dfs -put /home/data/static_data /ola/static_data
docker exec $HDFS_CONTAINER hdfs dfs -put /home/data/historical_data /ola/historical_data

exit 0
