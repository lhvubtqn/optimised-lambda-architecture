#!/bin/bash

cd "$(dirname "$0")"

set -e

echo -e "\n🐳 Starting PySpark Notebook"
kubectl apply -f pyspark-notebook.yaml

CONTAINER_NAME=$(kubectl get pods -l app=pyspark-notebook -o name | cut -d/ -f 2)

echo -e "\n⏳ Waiting for PySpark Notebook to be up and running"
while true
do
  if [ $(kubectl logs $CONTAINER_NAME 2>&1 | grep "Jupyter Notebook .* is running" >/dev/null; echo $?) -eq 0 ]; then
    echo
    break
  fi
  printf "."
  sleep 1
done

echo -e "\n⏳Copy notebooks to container..."
kubectl cp ./notebooks $CONTAINER_NAME:/home/jovyan

echo -e "\n🏭 Pyspark Notebook: http://notebook.f7f408665cdc431daa59.westus2.aksapp.io/$(kubectl logs $CONTAINER_NAME 2>&1 | grep -oP 'http://127.0.0.1:8888/\K(.*)' | head -n 1)"

echo -e "\nDONE"

exit 0