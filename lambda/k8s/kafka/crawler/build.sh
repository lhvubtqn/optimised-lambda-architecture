#!/bin/sh

cd "$(dirname "$0")"

VERSION=v1

docker build -t lhvubtqn.azurecr.io/lametro-crawler:$VERSION .

docker push lhvubtqn.azurecr.io/lametro-crawler:$VERSION .