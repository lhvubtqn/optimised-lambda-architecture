#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                                  Storages                                ---"
echo "--------------------------------------------------------------------------------"

HDFS_CONTAINER=namenode

echo -e "\n⏳ Copying data folders to HDFS..."
unzip data.zip
docker exec $HDFS_CONTAINER bash -c "hdfs dfs -copyFromLocal /home/data/static_data/* /ola/static_data"
docker exec $HDFS_CONTAINER bash -c "hdfs dfs -copyFromLocal /home/data/aggregated_data/* /ola/aggregated_data"

exit 0
