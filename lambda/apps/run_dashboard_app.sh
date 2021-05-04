#!/bin/sh

cd "$(dirname "$0")"

docker run -d --name iot-springboot-dashboard \
    --network lambda-network \
    --volumes iot-springboot-dashboard/target/iot-springboot-dashboard-1.0.0.jar /iot-springboot-dashboard-1.0.0.jar \
    --publish 3000:3000 \
    java:8 java -jar /iot-springboot-dashboard-1.0.0.jar