#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

COMMAND="MASTER_INTERNAL_ADDRESS=$MASTER_INTERNAL_ADDRESS $@"

echo -e "\n🏭 Run '$@' on '$MASTER_ADDRESS'"
ssh -i $SSH_KEY_PATH $SSH_USERNAME@$MASTER_ADDRESS "$COMMAND"

exit 0