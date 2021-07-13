#!/bin/bash

cd "$(dirname "$0")"

set -e

./stop.sh

if [[ "$(docker network ls | grep lambda-network 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating network lambda-network\n"
  docker network create -d bridge lambda-network
fi

if [[ "$(docker volume ls | grep timescaledb-data 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume timescaledb-data\n"
  docker volume create timescaledb-data
fi

if [[ "$(docker volume ls | grep redis-data 2> /dev/null)" == "" ]]; then
  echo -e "\n🏭 Creating volume redis-data\n"
  docker volume create redis-data
fi

echo -e "\n🐳 Starting databases"
docker-compose up -d --remove-orphans

sleep 5

TIMESCALEDB_CONTAINER=timescaledb
DATABASE_NAME=lametro
TABLE_NAME=predictions
SQL_DIR=/home/sql

echo -e "\n⏳ Create database $DATABASE_NAME and create extension 'timescaledb' if not exist..."
docker exec $TIMESCALEDB_CONTAINER bash -c "psql -U postgres -h localhost < $SQL_DIR/create_database.sql"

echo -e "\n⏳ Create hypertable $TABLE_NAME..."
docker exec $TIMESCALEDB_CONTAINER bash -c "psql -U postgres -h localhost < $SQL_DIR/create_table.sql"


exit 0
