#!/bin/bash

cd "$(dirname "$0")"

. constants.cfg

mkdir -p jupyter/logs

# Export environment
export JAVA_HOME=$(pwd)/libs/jdk-11.0.11
export SPARK_HOME=$(pwd)/libs/spark-3.1.1-bin-hadoop3.2
export PATH=$SPARK_HOME/bin:$PATH

nohup ~/.local/bin/jupyter-notebook --ip=0.0.0.0 --notebook-dir notebooks > jupyter/logs/jupyter_notebook.logs 2> jupyter/logs/jupyter_notebook.logs & 

sleep 5

PUBLIC_IP=$(curl -s ipinfo.io/ip)
ACCESS_TOKEN=$(cat jupyter/logs/jupyter_notebook.logs 2>&1 | grep -oP 'http://127.0.0.1:8888/?token=\K(.*)' | head -n 1)

echo -e "\n🏭 Access using public IP: http://$PUBLIC_IP:8888/?token=$ACCESS_TOKEN"
echo -e "\n🏭 Access using localhost: http://localhost:8888/?token=$ACCESS_TOKEN"

exit 0