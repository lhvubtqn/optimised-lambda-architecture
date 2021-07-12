#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

COMMAND=$@

echo -e "\n🏭 Run '$COMMAND' on server '$MASTER_ADDRESS'"
ssh -i $SSH_KEY_PATH $SSH_USERNAME@$MASTER_ADDRESS $COMMAND

exit 0