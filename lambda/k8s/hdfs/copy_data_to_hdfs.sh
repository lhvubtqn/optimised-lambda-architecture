#!/bin/bash

cd "$(dirname "$0")"

set -e

_CLIENT=$(kubectl get pods -l app=hdfs-client,release=k8s-hdfs -o name | cut -d/ -f 2)

echo -e "\n⏳ Copying data folders to HDFS..."

[ ! -d "$(pwd)/data" ] && unzip -q data.zip

kubectl exec $_CLIENT -- bash -c '[ ! -d "/var/local/data" ]' 2> /dev/null && kubectl cp ./data $_CLIENT:/var/local
kubectl exec $_CLIENT -- hdfs dfs -copyFromLocal /var/local/data/static_data/* /ola/static_data
kubectl exec $_CLIENT -- hdfs dfs -copyFromLocal /var/local/data/aggregated_data/* /ola/aggregated_data

exit 0
