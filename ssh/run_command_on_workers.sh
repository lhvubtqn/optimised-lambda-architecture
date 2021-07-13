#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

COMMAND="MASTER_INTERNAL_ADDRESS=$MASTER_INTERNAL_ADDRESS $@"

for i in $(eval echo "{1..$WORKER_NUM}"); do
    WORKER_ADDRESS="WORKER_ADDRESS_${i}"
    echo -e "\n🏭 Run '$@' on '${!WORKER_ADDRESS}'"
    ssh -i $SSH_KEY_PATH $SSH_USERNAME@${!WORKER_ADDRESS} "$COMMAND"
done

exit 0