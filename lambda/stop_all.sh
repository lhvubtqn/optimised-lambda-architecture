#!/bin/sh

cd "$(dirname "$0")"

(cd kafka && ./stop.sh)
(cd hdfs && ./stop.sh)
(cd clickhouse && ./stop.sh)
(cd spark && ./stop.sh)