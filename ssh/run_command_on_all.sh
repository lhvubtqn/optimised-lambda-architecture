#!/bin/bash

set -e

$(dirname "$0")/run_command_on_master.sh $@
$(dirname "$0")/run_command_on_workers.sh $@

exit 0