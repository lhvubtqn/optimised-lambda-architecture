#!/bin/sh

cd "$(dirname "$0")"

(cd kafka && ./stop.sh)
(cd storage && ./stop.sh)
(cd spark && ./stop.sh)