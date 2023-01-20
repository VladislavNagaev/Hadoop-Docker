#!/bin/bash

COMMAND="${1:-}"

source /entrypoint/hadoop-wait_for_it.sh

source /entrypoint/hadoop-configure.sh

source /entrypoint/hadoop-initialization.sh $COMMAND

