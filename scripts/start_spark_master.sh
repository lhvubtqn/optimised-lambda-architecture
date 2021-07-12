#!/bin/bash

cd "$(dirname "$0")"

# Require environment: MASTER_INTERNAL_ADDRESS=<internal master address>
# This address should be accessible from workers

if [ "$MASTER_INTERNAL_ADDRESS" = "" ]; then
    MASTER_INTERNAL_ADDRESS=$(hostname -i)
fi

# Download Apache Spark
if [ ! -d ./libs/spark-3.1.1-bin-hadoop3.2 ]; then
  echo -e "\n⏳ Downloading spark-3.1.1-bin-hadoop3.2"
  (cd ./libs && \
  curl -O https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz && \
  tar -xvf spark-3.1.1-bin-hadoop3.2.tgz && \
  rm spark-3.1.1-bin-hadoop3.2.tgz)
fi

# Export environment, JAVA_HOME should already be set
export SPARK_HOME=$(pwd)/libs/spark-3.1.1-bin-hadoop3.2
export PATH=$SPARK_HOME/bin:$PATH

SPARK_MASTER_HOST=$MASTER_INTERNAL_ADDRESS $SPARK_HOME/sbin/start-master.sh

exit 0