#!/bin/sh

cd "$(dirname "$0")"

helm uninstall k8s-hdfs

helm dependency build charts/hdfs-k8s

kubectl label nodes aks-agentpool-11552782-vmss000001 hdfs-namenode-selector=hdfs-namenode-0 --overwrite

helm install k8s-hdfs charts/hdfs-k8s \
    --set tags.ha=false \
    --set tags.simple=true \
    --set global.namenodeHAEnabled=false \
    --set hdfs-simple-namenode-k8s.nodeSelector.hdfs-namenode-selector=hdfs-namenode-0

kubectl get pod -l release=k8s-hdfs