#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export HADOOP_HOME=$(pwd)/libs/hadoop-3.2.2
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Stop namenode if exists
$HADOOP_HOME/bin/hdfs --daemon stop namenode

exit 0