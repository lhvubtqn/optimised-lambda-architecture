#!/bin/sh

cd "$(dirname "$0")"

docker exec spark-master spark-submit \
    --deploy-mode cluster \
    --master spark://spark-master:7077 \
    --properties-file /opt/bitnami/spark/conf/spark-defaults.conf \
    --class com.apssouza.iot.processor.StreamingProcessor \
    --name "IoT Data Stream Processor" \
    /opt/spark/apps/iot-spark-processor-1.0.0.jar