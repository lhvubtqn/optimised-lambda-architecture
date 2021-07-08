#!/bin/bash

cd "$(dirname "$0")"

set -e

_CLIENT=$(kubectl get pods -l app=hdfs-client,release=k8s-hdfs -o name | cut -d/ -f 2)

echo -e "\n⏳ Creating folders on HDFS & change permission..."
kubectl exec $_CLIENT -- hdfs dfs -mkdir /spark
kubectl exec $_CLIENT -- hdfs dfs -mkdir /spark/checkpoint
kubectl exec $_CLIENT -- hdfs dfs -mkdir /ola
kubectl exec $_CLIENT -- hdfs dfs -mkdir /ola/static_data
kubectl exec $_CLIENT -- hdfs dfs -mkdir /ola/historical_data
kubectl exec $_CLIENT -- hdfs dfs -mkdir /ola/aggregated_data
kubectl exec $_CLIENT -- hdfs dfs -mkdir /temp

kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /spark
kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /spark/checkpoint
kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /ola
kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /ola/static_data
kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /ola/historical_data
kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /ola/aggregated_data
kubectl exec $_CLIENT -- hdfs dfs -chmod -R 777 /temp

exit 0
