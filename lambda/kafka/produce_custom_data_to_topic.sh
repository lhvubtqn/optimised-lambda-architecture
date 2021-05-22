#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                               Kafka Cluster                              ---"
echo "--------------------------------------------------------------------------------"

echo -e "\n⏳ Producing records to topic $1 with format <key>:<value>"
docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic $1 --property 'parse.key=true' --property 'key.separator=:'

exit 0