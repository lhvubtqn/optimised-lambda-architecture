#!/bin/bash

cd "$(dirname "$0")"

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

echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://'$MASTER_INTERNAL_ADDRESS':8020</value>
    </property>
</configuration>
' > $HADOOP_HOME/etc/hadoop/core-site.xml

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
</configuration>
' > $HADOOP_HOME/etc/hadoop/hdfs-site.xml 

rm $HADOOP_HOME/etc/hadoop/workers
for i in $(eval echo "{1..$WORKER_NUM}"); do
    WORKER_INTERNAL_ADDRESS="WORKER_INTERNAL_ADDRESS_${i}"
    echo "${!WORKER_INTERNAL_ADDRESS}" >> $HADOOP_HOME/etc/hadoop/workers
done

exit 0