#!/bin/sh

cd "$(dirname "$0")"

docker exec spark-master spark-submit \
    --name "IoT Data Streaming Processor" \
    --deploy-mode cluster \
    --master spark://spark-master:7077 \
    --properties-file /opt/bitnami/spark/conf/spark-defaults.conf \
    --class com.apssouza.iot.processor.StreamingProcessor \
    /opt/spark/apps/iot-spark-processor-1.0.0.jar