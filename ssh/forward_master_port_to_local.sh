#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

ssh -i $SSH_KEY_PATH -L $1:0.0.0.0:$1 $SSH_USERNAME@$MASTER_ADDRESS

exit 0