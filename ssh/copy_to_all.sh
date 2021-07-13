#!/bin/bash

set -e

$(dirname "$0")/copy_to_master.sh $@
$(dirname "$0")/copy_to_workers.sh $@

exit 0