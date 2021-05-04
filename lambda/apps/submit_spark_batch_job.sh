#!/bin/sh

cd "$(dirname "$0")"

docker exec spark-master spark-submit \
    --deploy-mode cluster \
    --class com.apssouza.iot.processor.BatchProcessor \
    --master spark://localhost:7077 \
    /opt/spark/apps/iot-spark-processor-1.0.0.jar