#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export HADOOP_HOME=$(pwd)/libs/hadoop-3.2.2
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Format hdfs namenode
$HADOOP_HOME/bin/hdfs namenode -format

# Start hdfs
$HADOOP_HOME/sbin/start-dfs.sh

PUBLIC_IP=$(curl -s ipinfo.io/ip)
echo -e "\n🏭 Access using public IP: http://$PUBLIC_IP:9870/"
echo -e "\n🏭 Access using local: http://locahost:9870/"

exit 0