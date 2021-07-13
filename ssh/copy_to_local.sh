#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

SRC_PATH=$MASTER_ADDRESS:$1
DES_PATH=$2

echo -e "\n⏳ Copy '$SRC_PATH' to '$2'..."
rsync -rv --delete --links -e "ssh -i $SSH_KEY_PATH" $SSH_USERNAME@$SRC_PATH $DES_PATH

exit 0