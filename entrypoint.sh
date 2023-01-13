#!/bin/bash

COMMAND="${1:-}"

# Set some sensible defaults
export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://`hostname -f`:8020}

function addProperty() {

  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')

  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path

}

function configure() {

    local path=$1
    local envPrefix=$2

    local var
    local value
    
    echo "Configuring $path"

    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

configure ${HADOOP_CONF_DIR}/core-site.xml CORE_CONF
configure ${HADOOP_CONF_DIR}/hdfs-site.xml HDFS_CONF
configure ${HADOOP_CONF_DIR}/yarn-site.xml YARN_CONF
configure ${HADOOP_CONF_DIR}/httpfs-site.xml HTTPFS_CONF
configure ${HADOOP_CONF_DIR}/kms-site.xml KMS_CONF
configure ${HADOOP_CONF_DIR}/mapred-site.xml MAPRED_CONF

function wait_for_it() {

    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_try=100

    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do

      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"

      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."

      let "i++"

      sleep $retry_seconds
      nc -z $service $port
      result=$?

    done

    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done


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

exec $@