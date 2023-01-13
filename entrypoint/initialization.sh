#!/bin/bash

COMMAND="${1:-}"

if [ "${COMMAND}" == "namenode" ]; then

    echo "Starting Hadoop namenode ..."

    HDFS_CONF_dfs_namenode_name_path=`echo ${HDFS_CONF_dfs_namenode_name_dir} | perl -pe 's#file://##'`

    mkdir -p ${HDFS_CONF_dfs_namenode_name_path}

    if [ -z "${CLUSTER_NAME}" ]; then
        echo "Cluster name not specified"
        exit 2
    fi

    # run the DFS namenode at first time
    if [ "`ls -A ${HDFS_CONF_dfs_namenode_name_path}`" == "" ]; then
        echo "Formatting namenode name directory: ${HDFS_CONF_dfs_namenode_name_path}"
        ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode -format ${CLUSTER_NAME}
    fi

    ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode

fi

if [ "${COMMAND}" == "datanode" ]; then

    echo "Starting Hadoop datanode ..."

    HDFS_CONF_dfs_datanode_data_path=`echo ${HDFS_CONF_dfs_datanode_data_dir} | perl -pe 's#file://##'`

    mkdir -p ${HDFS_CONF_dfs_datanode_data_path}

    ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} datanode

fi

if [ "${COMMAND}" == "historyserver" ]; then

    echo "Starting Hadoop historyserver ..."

    mkdir -p ${YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path}

    ${HADOOP_HOME}/bin/yarn --config ${HADOOP_CONF_DIR} historyserver

fi

if [ "${COMMAND}" == "nodemanager" ]; then

    echo "Starting Hadoop nodemanager ..."

    ${HADOOP_HOME}/bin/yarn --config ${HADOOP_CONF_DIR} nodemanager

fi

if [ "${COMMAND}" == "resourcemanager" ]; then

    echo "Starting Hadoop resourcemanager ..."

    ${HADOOP_HOME}/bin/yarn --config ${HADOOP_CONF_DIR} resourcemanager

fi
