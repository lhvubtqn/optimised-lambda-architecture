#!/bin/bash

cd "$(dirname "$0")"

set -e

echo -e "\n🐳 Stopping Grafana..."
docker-compose down -v --remove-orphans

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

if [[ "$(docker volume ls | grep lambda-grafana-storage 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume lambda-grafana-storage\n"
  docker volume create lambda-grafana-storage
fi

echo -e "\n🐳 Starting Grafana..."
docker-compose up -d

PUBLIC_IP=$(curl -s ipinfo.io/ip)
echo -e "\n🏭 Access using public IP: http://$PUBLIC_IP:3000/"
echo -e "\n🏭 Access using local: http://locahost:3000/"

exit 0