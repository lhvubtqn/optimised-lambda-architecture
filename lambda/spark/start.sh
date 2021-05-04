#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                               Spark Cluster                              ---"
echo "--------------------------------------------------------------------------------"

echo -e "\n🐳 Stopping Spark cluster"
docker-compose down -v --remove-orphans

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

SOURCE_JAR_FILE=../apps/iot-spark-processor/target/iot-spark-processor-1.0.0.jar

if [ ! -f "$SOURCE_JAR_FILE" ] || [ ! $# -eq 0 ]; then
    echo -e "\n🏭 Building iot-spark-processor project...\n"
    (cd "$(dirname "$SOURCE_JAR_FILE")/../"; mvn clean -q package -Dmaven.test.skip=true)
fi

echo -e "\n🐳 Starting Spark cluster"
docker-compose up -d --remove-orphans

exit 0