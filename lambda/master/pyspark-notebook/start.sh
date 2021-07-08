#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                             PySpark Notebook                             ---"
echo "--------------------------------------------------------------------------------"

if [ ! -d ./spark-3.1.1-bin-hadoop3.2 ]; then
  echo -e "\n⏳ Downloading spark-3.1.1-bin-hadoop3.2"
  (curl -O https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz && \
  tar -xzf spark-3.1.1-bin-hadoop3.2.tgz && \
  rm spark-3.1.1-bin-hadoop3.2.tgz)
fi

export SPARK_HOME=$(pwd)/spark-3.1.1-bin-hadoop3.2
export PATH=$SPARK_HOME/bin:$PATH

sudo apt-get install -y python3-pip

pip3 install jupyter

export PATH=$PATH:~/.local/bin

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'

pyspark

# https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz

# echo -e "\n🐳 Stopping PySpark Notebook"
# docker-compose down -v --remove-orphans

# if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
#   echo -e "\n🏭 Creating network lambda-network\n"
#   docker network create -d bridge lambda-network
# fi

# echo -e "\n🐳 Starting PySpark Notebook"
# docker-compose up -d

# CONTAINER_NAME=pyspark-notebook
# echo -e "\n⏳ Waiting for PySpark Notebook to be up and running"
# while true
# do
#   if [ $(docker logs $CONTAINER_NAME 2>&1 | grep "Jupyter Notebook .* is running" >/dev/null; echo $?) -eq 0 ]; then
#     echo
#     break
#   fi
#   printf "."
#   sleep 1
# done

# echo -e "\n⏳ Starting Spark Master..."
# output_file=$(docker exec $CONTAINER_NAME bash -c "cd /usr/local/spark/sbin && ./start-master.sh | grep -oP 'logging to \K.*'")
# sleep 5

# spark_master_address=$(docker exec $CONTAINER_NAME cat $output_file | grep -oP "Starting Spark master at \K.*")
# echo -e "\nMaster address: $spark_master_address"

# echo -e "\n🏭 Pyspark Notebook: $(docker logs $CONTAINER_NAME 2>&1 | grep -oP '\K(http://127.0.0.1:8888.*)' | head -n 1)"

# echo -e "\nDONE"

exit 0