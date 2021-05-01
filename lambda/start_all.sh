#!/bin/sh

cd "$(dirname "$0")"

(cd kafka && ./start.sh)
(cd hdfs && ./start.sh)
(cd clickhouse && ./start.sh)
(cd spark && ./start.sh)