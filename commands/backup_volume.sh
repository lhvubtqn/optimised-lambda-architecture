#!/bin/bash

set -e

cd "$(dirname "$0")"

docker run --rm --volumes-from $1 -v $(pwd)/../volumes:/volumes node:14.15.1 tar cvf /volumes/$1.tar $2

exit 0