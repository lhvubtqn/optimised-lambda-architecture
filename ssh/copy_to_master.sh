#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

SRC_PATH=$1
DES_PATH=$MASTER_ADDRESS:$2

echo -e "\n⏳ Copy '$SRC_PATH' to MASTER at '$DES_PATH'..."
rsync -P -rv --delete --links -e "ssh -i $SSH_KEY_PATH" $SRC_PATH $SSH_USERNAME@$DES_PATH

exit 0