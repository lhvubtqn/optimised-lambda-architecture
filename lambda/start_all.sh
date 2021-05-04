#!/bin/sh

cd "$(dirname "$0")"

(cd kafka && ./start.sh)
(cd storage && ./start.sh)
(cd spark && ./start.sh -b)