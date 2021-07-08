#!/bin/sh

cd "$(dirname "$0")"

kubectl apply -f zookeeper.yaml,kafka.yaml,crawler.yaml

KAFKA_POD_NAME=$(kubectl get pods -l app=kafka -o name | cut -d/ -f 2)

echo "\n⏳ Waiting for Kafka Broker to be up and running"
while true
do
  if [ $(kubectl logs $KAFKA_POD_NAME 2>&1 | grep "started (kafka.server.KafkaServer)" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo "\n⏳ Creating Kafka topics"
kubectl exec $KAFKA_POD_NAME -- kafka-topics --zookeeper zookeeper:2181 --create --topic buses-location --partitions 8 --replication-factor 1 --config retention.bytes=102400