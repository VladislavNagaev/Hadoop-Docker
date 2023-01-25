#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "namenode" ]; then

    echo "Ending Hadoop namenode ..."

    ${HADOOP_HOME}/bin/hdfs --daemon stop namenode

fi

if [ "${COMMAND}" == "datanode" ]; then

    echo "Ending Hadoop datanode ..."


    ${HADOOP_HOME}/bin/hdfs --daemon stop datanode

fi

if [ "${COMMAND}" == "historyserver" ]; then

    echo "Ending Hadoop historyserver ..."

    ${HADOOP_HOME}/bin/yarn --daemon stop historyserver

fi

if [ "${COMMAND}" == "nodemanager" ]; then

    echo "Ending Hadoop nodemanager ..."

    ${HADOOP_HOME}/bin/yarn --daemon stop nodemanager

fi

if [ "${COMMAND}" == "resourcemanager" ]; then

    echo "Ending Hadoop resourcemanager ..."

    ${HADOOP_HOME}/bin/yarn --daemon stop resourcemanager

fi

exit $?
