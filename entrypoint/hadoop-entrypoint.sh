#!/bin/bash

COMMAND="${1:-}";

hadoop-termination() {
    source /entrypoint/hadoop-termination.sh $COMMAND;
};

source /entrypoint/wait_for_it.sh;

source /entrypoint/font-colors.sh;
source /entrypoint/hadoop-configure.sh;

source /entrypoint/hadoop-initialization.sh $COMMAND &

trap hadoop-termination SIGTERM HUP INT QUIT TERM;

# Wait for any process to exit
wait -n;
