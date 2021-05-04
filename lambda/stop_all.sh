#!/bin/sh

cd "$(dirname "$0")"

(cd spark && ./stop.sh)
(cd storage && ./stop.sh)
(cd kafka && ./stop.sh)