#!/bin/bash

set -e

CONNECT_CONTAINER_NAME=datagen

echo -e "\n⏳ Resubmiting datagen configurations..."
docker exec -it $CONNECT_CONTAINER_NAME curl -s -X DELETE http://localhost:8083/connectors/datagen > /dev/null
docker exec -it $CONNECT_CONTAINER_NAME curl -s -X POST -H "Content-Type: application/json" -d "@/usr/share/datagen/configs/datagen_connector.config" http://localhost:8083/connectors | jq .

exit 0