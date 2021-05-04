#!/bin/sh

cd "$(dirname "$0")"

docker stop iot-springboot-dashboard 2> /dev/null || true
docker rm iot-springboot-dashboard 2> /dev/null || true

docker run -d --name iot-springboot-dashboard \
    --network lambda-network \
    --volume $(pwd)/iot-springboot-dashboard/target/iot-springboot-dashboard-1.0.0.jar:/iot-springboot-dashboard-1.0.0.jar \
    --publish 3000:3000 \
    java:8 java -jar /iot-springboot-dashboard-1.0.0.jar