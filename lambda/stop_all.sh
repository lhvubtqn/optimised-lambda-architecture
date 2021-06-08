#!/bin/sh

cd "$(dirname "$0")"

(cd pyspark-notebook && ./stop.sh)
(cd kafka && ./stop.sh)
(cd storage && ./stop.sh)