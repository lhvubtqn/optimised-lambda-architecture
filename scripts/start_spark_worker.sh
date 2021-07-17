#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Require environment: MASTER_INTERNAL_ADDRESS=<internal master address>
# This address should be accessible from workers
# if [ "$MASTER_INTERNAL_ADDRESS" = "" ]; then
#     MASTER_INTERNAL_ADDRESS=
# fi

# Download Apache Spark
if [ ! -d ./libs/spark-3.1.1-bin-hadoop3.2 ]; then
  echo -e "\n⏳ Downloading spark-3.1.1-bin-hadoop3.2"
  (cd ./libs && \
  curl -O https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz && \
  tar -xf spark-3.1.1-bin-hadoop3.2.tgz && \
  rm spark-3.1.1-bin-hadoop3.2.tgz)
fi

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export SPARK_HOME=$(pwd)/libs/spark-3.1.1-bin-hadoop3.2
export PATH=$SPARK_HOME/bin:$PATH

# Stop worker if exist
$SPARK_HOME/sbin/stop-worker.sh > /dev/null 2> /dev/null

# Start Spark Master
SPARK_LOCAL_IP=$WORKER_INTERNAL_ADDRESS SPARK_WORKER_MEMORY=3g SPARK_WORKER_PORT=7070 $SPARK_HOME/sbin/start-worker.sh spark://$MASTER_INTERNAL_ADDRESS:7077

exit 0