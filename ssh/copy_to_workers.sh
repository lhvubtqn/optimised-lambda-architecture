#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

for i in $(eval echo "{1..$WORKER_NUM}"); do
    $(dirname "$0")/copy_to_worker.sh $i $@
done

exit 0