#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

# usage: ./copy_to_worker.sh <worker_id> <src_path> <des_path>

WORKER_ADDRESS="WORKER_ADDRESS_$1"
SRC_PATH=$2
DES_PATH=${!WORKER_ADDRESS}:$3

echo -e "\n⏳ Copy '$SRC_PATH' to WORKER_${1} at '$DES_PATH'..."
rsync -P -rv --delete --links -e "ssh -i $SSH_KEY_PATH" $SRC_PATH $SSH_USERNAME@$DES_PATH

exit 0