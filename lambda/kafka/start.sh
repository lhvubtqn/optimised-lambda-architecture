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

mkdir datagen/plugins 2> /dev/null || true

if [ ! -d ./datagen/plugins/confluentinc-kafka-connect-datagen-0.4.0 ]; then
  echo -e "\n⏳ Downloading connect-datagen:0.4.0"
  (cd ./datagen/plugins && \
  curl -O https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-datagen/versions/0.4.0/confluentinc-kafka-connect-datagen-0.4.0.zip && \
  unzip -q confluentinc-kafka-connect-datagen-0.4.0.zip && \
  rm confluentinc-kafka-connect-datagen-0.4.0.zip)
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
docker exec -it $KAFKA_CONTAINER_NAME kafka-topics --zookeeper zookeeper:2181 --create --topic iot-data-event --partitions 8 --replication-factor 1 --config retention.bytes=102400

CONTAINER_NAME=datagen
echo -e "\n⏳ Waiting for Datagen Container to be up and running"
while true
do
  if [ $(docker logs $CONTAINER_NAME 2>&1 | grep "REST resources initialized; server is started and ready to handle requests" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo -e "\n⏳ Creating Datagen Connector..."
docker exec -it $CONTAINER_NAME curl -s -X DELETE http://localhost:8083/connectors/$1 > /dev/null
docker exec -it $CONTAINER_NAME curl -s -X POST -H "Content-Type: application/json" -d "@/usr/share/datagen/configs/datagen_connector.config" http://localhost:8083/connectors > /dev/null
echo -e "Created Datagen Connector." 

exit 0