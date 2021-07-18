#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export SPARK_HOME=$(pwd)/libs/spark-3.1.1-bin-hadoop3.2
export PATH=$SPARK_HOME/bin:$PATH

# Stop worker if exist
$SPARK_HOME/sbin/stop-worker.sh

exit 0