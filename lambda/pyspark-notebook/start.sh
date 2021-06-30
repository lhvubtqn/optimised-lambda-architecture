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

CONTAINER_NAME=pyspark-notebook
echo -e "\n⏳ Waiting for PySpark Notebook to be up and running"
while true
do
  if [ $(docker logs $CONTAINER_NAME 2>&1 | grep "Jupyter Notebook 6.3.0 is running" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo -e "\n⏳ Starting Spark Master..."

output_file=$(docker exec $CONTAINER_NAME bash -c "cd /usr/local/spark/sbin && ./start-master.sh | grep -oP 'logging to \K.*'")
spark_master_address=$(docker exec $CONTAINER_NAME cat $output_file | grep -oP "Starting Spark master at \K.*")

echo -e "\n⏳ Starting 2 workers with 4 cores & 4g memory each..."
config='
SPARK_WORKER_INSTANCES=2
SPARK_WORKER_CORES=4
SPARK_WORKER_MEMORY=4g
'
docker exec $CONTAINER_NAME bash -c "echo '$config' > /usr/local/spark/conf/spark-env.sh && /usr/local/spark/sbin/start-worker.sh $spark_master_address" > /dev/null

echo -e "\n🏭 Pyspark Notebook: $(docker logs $CONTAINER_NAME 2>&1 | grep -oP '\K(http://127.0.0.1:8888.*)' | head -n 1)"

echo -e "\nDONE"

exit 0