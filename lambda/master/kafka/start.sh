#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                               Kafka Cluster                              ---"
echo "--------------------------------------------------------------------------------"

./stop.sh

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

echo -e "\n🐳 Starting Kafka cluster"
docker-compose up -d --remove-orphans

KAFKA_CONTAINER_NAME=kafka
echo -e "\n⏳ Waiting for Kafka Broker to be up and running"
while true
do
  if [ $(docker logs $KAFKA_CONTAINER_NAME 2>&1 | grep "started (kafka.server.KafkaServer)" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo -e "\n⏳ Creating Kafka topics"
docker exec -it $KAFKA_CONTAINER_NAME kafka-topics --zookeeper zookeeper:2181 --create --topic buses-location --partitions 8 --replication-factor 1 --config retention.bytes=102400

exit 0