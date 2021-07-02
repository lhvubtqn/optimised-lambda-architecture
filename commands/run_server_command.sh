#!/bin/bash

set -e

. $(dirname "$0")/constants.cfg

SERVER_ADDRESSES=$(eval
    for i in $(eval echo "{1..$SERVER_NUMBER}"); do
        server_address="SERVER${i}_ADDRESS"
        echo ${!server_address}
    done
)
SERVER_ADDRESSES=$(echo $SERVER_ADDRESSES | sed 's/\s/,/g')

for i in $(eval echo "{1..$SERVER_NUMBER}"); do
    server_address="SERVER${i}_ADDRESS"
    echo -e "\n🏭 Run command '$@' on server '${!server_address}'"
    ssh -i $SSH_KEY_PATH $SERVER_USER@${!server_address} $@
done

exit 0