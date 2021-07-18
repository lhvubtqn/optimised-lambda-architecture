#!/bin/bash

cd "$(dirname "$0")"

# Usage: ./start_namenode.sh [-format]
# Config HDFS. If -format provided, will delete old data & format namenode.

. constants.cfg

# Download HDFS
if [ ! -d ./libs/hadoop-3.2.2 ]; then
  echo -e "\n⏳ Downloading hadoop-3.2.2"
  (cd ./libs && \
  curl -O https://mirror.downloadvn.com/apache/hadoop/common/hadoop-3.2.2/hadoop-3.2.2.tar.gz && \
  tar -xf hadoop-3.2.2.tar.gz && \
  rm hadoop-3.2.2.tar.gz)
fi

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export HADOOP_HOME=$(pwd)/libs/hadoop-3.2.2
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Stop namenode if exists
$HADOOP_HOME/bin/hdfs --daemon stop namenode > /dev/null 2> /dev/null

echo "
export JAVA_HOME=$JAVA_HOME
export HDFS_NAMENODE_USER=$SSH_USERNAME
export HDFS_DATANODE_USER=$SSH_USERNAME
export HDFS_SECONDARYNAMENODE_USER=$SSH_USERNAME
" > $HADOOP_HOME/etc/hadoop/hadoop-env.sh

echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://'$MASTER_INTERNAL_ADDRESS':8020</value>
    </property>
</configuration>
' > $HADOOP_HOME/etc/hadoop/core-site.xml

if [[ "$1" == "-format" ]]; then
    # Delete old data if exists
    rm -rf $HADOOP_HOME/data/
fi

mkdir -p $HADOOP_HOME/data/{namenode,datanode}
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
      <name>dfs.namenode.name.dir</name>
      <value>'$HADOOP_HOME'/data/namenode</value>
    </property>
    <property>
      <name>dfs.datanode.data.dir</name>
      <value>'$HADOOP_HOME'/data/datanode</value>
    </property>
    <property>
      <name>dfs.replication</name>
      <value>1</value>
    </property>
    <property>
      <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
      <value>false</value>
    </property>
</configuration>
' > $HADOOP_HOME/etc/hadoop/hdfs-site.xml 

rm $HADOOP_HOME/etc/hadoop/workers
for i in $(eval echo "{1..$WORKER_NUM}"); do
    WORKER_INTERNAL_ADDRESS="WORKER_INTERNAL_ADDRESS_${i}"
    echo "${!WORKER_INTERNAL_ADDRESS}" >> $HADOOP_HOME/etc/hadoop/workers
done


if [[ "$1" == "-format" ]]; then
    # Format hdfs namenode
    $HADOOP_HOME/bin/hdfs namenode -format
fi

# Start namenode
$HADOOP_HOME/bin/hdfs --daemon start namenode

PUBLIC_IP=$(curl -s ipinfo.io/ip)
echo -e "\n🏭 Access using public IP: http://$PUBLIC_IP:9870/"
echo -e "\n🏭 Access using local: http://locahost:9870/"

exit 0