#!/bin/bash

cd "$(dirname "$0")"

set -e

# Main
echo "--------------------------------------------------------------------------------"
echo "---                                  Storages                                ---"
echo "--------------------------------------------------------------------------------"

TIMESCALEDB_CONTAINER=timescaledb
DATABASE_NAME=lametro
TABLE_NAME=predictions
SQL_DIR=/home/sql

echo -e "\n⏳ Create database $DATABASE_NAME and create extension 'timescaledb' if not exist..."
docker exec $TIMESCALEDB_CONTAINER bash -c "psql -U postgres -h localhost < $SQL_DIR/create_database.sql"

echo -e "\n⏳ Create hypertable $TABLE_NAME..."
docker exec $TIMESCALEDB_CONTAINER bash -c "psql -U postgres -h localhost < $SQL_DIR/create_table.sql"

exit 0
