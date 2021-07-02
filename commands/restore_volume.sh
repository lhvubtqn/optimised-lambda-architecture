#!/bin/bash

set -e

cd "$(dirname "$0")"

docker run --rm --volumes-from $1 -v $2:/volumes node:14.15.1 bash -c "cd $3 && tar xvf /volumes/$1.tar --strip 1"

exit 0