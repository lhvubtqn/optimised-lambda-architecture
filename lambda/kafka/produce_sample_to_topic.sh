#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                               Kafka Cluster                              ---"
echo "--------------------------------------------------------------------------------"

echo -e "\n⏳ Producing sample records to topic $1 with key null"
docker exec kafka bash -c "kafka-console-producer --bootstrap-server localhost:9092 --topic $1 --property 'parse.key=true' --property 'key.separator=:::' < /home/data/sample.data"

exit 0