#!/bin/bash

COMMAND="${1:-}";


if [ "${COMMAND}" == "namenode" ]; then

    echo -e "${blue_b}Ending Hadoop namenode ...${reset_font}";

    ${HADOOP_HOME}/bin/hdfs --daemon stop namenode;

fi;

if [ "${COMMAND}" == "datanode" ]; then

    echo -e "${blue_b}Ending Hadoop datanode ...${reset_font}";

    ${HADOOP_HOME}/bin/hdfs --daemon stop datanode;

fi;

if [ "${COMMAND}" == "historyserver" ]; then

    echo -e "${blue_b}Ending Hadoop historyserver ...${reset_font}";

    ${HADOOP_HOME}/bin/yarn --daemon stop historyserver;

fi;

if [ "${COMMAND}" == "nodemanager" ]; then

    echo -e "${blue_b}Ending Hadoop nodemanager ...${reset_font}";

    ${HADOOP_HOME}/bin/yarn --daemon stop nodemanager;

fi;

if [ "${COMMAND}" == "resourcemanager" ]; then

    echo -e "${blue_b}Ending Hadoop resourcemanager ...${reset_font}";

    ${HADOOP_HOME}/bin/yarn --daemon stop resourcemanager;

fi;

exit $?;
