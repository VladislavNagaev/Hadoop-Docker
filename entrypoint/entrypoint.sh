#!/bin/bash

COMMAND="${1:-}"

echo $COMMAND

source /entrypoint/wait_for_it.sh

source /entrypoint/configure.sh

source /entrypoint/initialization.sh $COMMAND

