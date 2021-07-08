#!/bin/sh

cd "$(dirname "$0")"

kubectl create clusterrolebinding spark-role-pod \
  --clusterrole=spark-role  \
  --serviceaccount=default:default

kubectl apply -f spark-role.yaml