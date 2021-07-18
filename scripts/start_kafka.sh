#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

# Download Apache Kafka
if [ ! -d ./libs/kafka_2.12-2.6.0 ]; then
  echo -e "\n⏳ Downloading kafka_2.12-2.6.0"
  (cd ./libs && \
  curl -O https://archive.apache.org/dist/kafka/2.6.0/kafka_2.12-2.6.0.tgz && \
  tar -xf kafka_2.12-2.6.0.tgz && \
  rm kafka_2.12-2.6.0.tgz)
fi

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export KAFKA_HOME=$(pwd)/libs/kafka_2.12-2.6.0
export PATH=$KAFKA_HOME/bin:$PATH

cd $KAFKA_HOME

mkdir -p logs

echo -e "\n🏭 Starting Zookeeper..."
nohup bin/zookeeper-server-start.sh config/zookeeper.properties > logs/zookeeper.logs 2> logs/zookeeper.logs &

echo -e "\n🏭 Starting Kafka..."
echo "advertised.listeners=PLAINTEXT://$MASTER_INTERNAL_ADDRESS:9092" >> config/server.properties
nohup bin/kafka-server-start.sh config/server.properties > logs/kafka.logs 2> logs/kafka.logs&

echo -e "\n⏳ Waiting for Kafka Broker to be up and running"
while true
do
  if [ $(cat logs/kafka.logs 2>&1 | grep "started (kafka.server.KafkaServer)" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo -e "\n⏳ Creating Kafka topics"
bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic buses-location --partitions 8 --replication-factor 1 --config retention.bytes=102400

exit 0