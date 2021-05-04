#!/bin/sh

cd "$(dirname "$0")"

docker stop iot-kafka-producer 2> /dev/null || true
docker rm iot-kafka-producer 2> /dev/null || true

docker run -d --name iot-kafka-producer \
    --network lambda-network \
    --volume $(pwd)/iot-kafka-producer/target/iot-kafka-producer-1.0.0.jar:/iot-kafka-producer-1.0.0.jar \
    java:8 java -jar /iot-kafka-producer-1.0.0.jar