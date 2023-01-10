#!/bin/bash

if [ ! -d $HDFS_CONF_dfs_datanode_data_path ]; then
    echo "Datanode data directory not found: $HDFS_CONF_dfs_datanode_data_path"
    exit 2
fi

# run the DFS datanode
$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR datanode
