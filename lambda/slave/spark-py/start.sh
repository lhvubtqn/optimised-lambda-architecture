#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                             PySpark Notebook                             ---"
echo "--------------------------------------------------------------------------------"

echo -e "\n🐳 Stopping PySpark Notebook"
docker-compose down -v --remove-orphans

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

echo -e "\n🐳 Starting PySpark Notebook"
docker-compose up -d

config='
SPARK_WORKER_INSTANCES=3
SPARK_WORKER_CORES=1
SPARK_WORKER_MEMORY=2g
'
echo -e "\n⏳ Starting Spark worker with 2 cores & 4g memory..."
spark_master_address="spark://master:7077"
docker exec $CONTAINER_NAME bash -c "echo '$config' > /usr/local/spark/conf/spark-env.sh && /usr/local/spark/sbin/start-worker.sh $spark_master_address -h $HOSTNAME -p 7070" > /dev/null

echo -e "\n🏭 Pyspark Notebook: $(docker logs $CONTAINER_NAME 2>&1 | grep -oP '\K(http://127.0.0.1:8888.*)' | head -n 1)"

echo -e "\nDONE"

exit 0