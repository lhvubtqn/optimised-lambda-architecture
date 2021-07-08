#!/bin/sh

cd "$(dirname "$0")"

kubectl get pod -l release=k8s-hdfs