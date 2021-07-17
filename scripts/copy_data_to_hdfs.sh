#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export HADOOP_HOME=$(pwd)/libs/hadoop-3.2.2

echo -e "\n⏳ Creating folders on HDFS & change permission..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark/checkpoint
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /ola
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /ola/static_data
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /ola/historical_data
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /ola/aggregated_data

$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /spark
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /spark/checkpoint
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /ola
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /ola/static_data
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /ola/historical_data
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /ola/aggregated_data

echo -e "\n⏳ Copying data folders to HDFS..."
curl -s -O https://oss.oracle.com/el4/unzip/unzip.tar && tar -xf unzip.tar && rm unzip.tar
./unzip -q data.zip -d $HADOOP_HOME/data/local && rm data.zip
$HADOOP_HOME/bin/hdfs dfs -copyFromLocal $HADOOP_HOME/data/local/data/static_data/* /ola/static_data
$HADOOP_HOME/bin/hdfs dfs -copyFromLocal $HADOOP_HOME/data/local/data/aggregated_data/* /ola/aggregated_data

exit 0