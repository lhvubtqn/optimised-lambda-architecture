#!/bin/bash 

cd "$(dirname "$0")"

set -e 

echo -e "\n🐳 Stopping ClickHouse"
docker-compose down -v --remove-orphans

exit 0
