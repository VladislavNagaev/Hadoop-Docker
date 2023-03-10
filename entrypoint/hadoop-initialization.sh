#!/bin/bash

COMMAND="${1:-}";


if [ "${COMMAND}" == "namenode" ]; then

    echo -e "${blue_b}Starting Hadoop namenode ...${reset_font}";

    HDFS_CONF_dfs_namenode_name_path=`echo ${HDFS_CONF_dfs_namenode_name_dir} | perl -pe 's#file://##'`;

    mkdir -p ${HDFS_CONF_dfs_namenode_name_path};

    if [ -z "${CLUSTER_NAME}" ]; then
        echo -e "${red_b}Cluster name not specified${reset_font}";
        exit 2;
    fi;

    # run the DFS namenode at first time
    if [ "`ls -A ${HDFS_CONF_dfs_namenode_name_path}`" == "" ]; then
        echo -e "${cyan_b}Formatting namenode name directory: ${HDFS_CONF_dfs_namenode_name_path}${reset_font}";
        ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode -format ${CLUSTER_NAME};
    fi;

    ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode;

fi;

if [ "${COMMAND}" == "datanode" ]; then

    echo -e "${blue_b}Starting Hadoop datanode ...${reset_font}";

    HDFS_CONF_dfs_datanode_data_path=`echo ${HDFS_CONF_dfs_datanode_data_dir} | perl -pe 's#file://##'`;

    mkdir -p ${HDFS_CONF_dfs_datanode_data_path};

    ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} datanode;

fi;

if [ "${COMMAND}" == "historyserver" ]; then

    echo -e "${blue_b}Starting Hadoop historyserver ...${reset_font}";

    mkdir -p ${YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path};

    ${HADOOP_HOME}/bin/yarn --config ${HADOOP_CONF_DIR} historyserver;

fi;

if [ "${COMMAND}" == "nodemanager" ]; then

    echo -e "${blue_b}Starting Hadoop nodemanager ...${reset_font}";

    mkdir -p ${YARN_CONF_yarn_nodemanager_remote___app___log___dir};

    ${HADOOP_HOME}/bin/yarn --config ${HADOOP_CONF_DIR} nodemanager;

fi;

if [ "${COMMAND}" == "resourcemanager" ]; then

    echo -e "${blue_b}Starting Hadoop resourcemanager ...${reset_font}";

    ${HADOOP_HOME}/bin/yarn --config ${HADOOP_CONF_DIR} resourcemanager;

fi

exit $?;
