#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

for i in $(eval echo "{1..$WORKER_NUM}"); do
    WORKER_ADDRESS="WORKER_ADDRESS_${i}"
    SRC_PATH=$1
    DES_PATH=${!WORKER_ADDRESS}:$2

    echo -e "\n⏳ Copy '$SRC_PATH' to '$DES_PATH'..."
    rsync -P -rv --delete --links -e "ssh -i $SSH_KEY_PATH" $SRC_PATH $SSH_USERNAME@$DES_PATH
done

exit 0