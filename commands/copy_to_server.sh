#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

for i in $(eval echo "{1..$SERVER_NUMBER}"); do
    server_address="SERVER${i}_ADDRESS"

    echo -e "\n⏳ Copy '$1' to server '${!server_address}'..."
    rsync -P -rv --delete --links -e "ssh -i $SSH_KEY_PATH" $1 $SERVER_USER@${!server_address}:$2
done

exit 0