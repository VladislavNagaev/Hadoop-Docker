#!/bin/bash

if [ ! -d $HDFS_CONF_dfs_namenode_name_path ]; then
    echo "Namenode name directory not found: $HDFS_CONF_dfs_namenode_name_path"
    exit 2
fi

if [ -z "$CLUSTER_NAME" ]; then
    echo "Cluster name not specified"
    exit 2
fi

if [ "`ls -A $HDFS_CONF_dfs_namenode_name_path`" == "" ]; then
    echo "Formatting namenode name directory: $HDFS_CONF_dfs_namenode_name_path"
    # run the DFS namenode at first time
    $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format $CLUSTER_NAME
fi

# run the DFS namenode
$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode

