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

exit 0