#!/bin/bash

echo -e "${blue_b}Hadoop-node configuration started ...${reset_font}";


function configure_conffile() {

    local path=$1;
    local envPrefix=$2;

    local var;
    local value;
    
    echo -e "${cyan_b}Configuring $path${reset_font}";

    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 

        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`;
        var="${envPrefix}_${c}";
        value=${!var};

        local entry="<property><name>$name</name><value>${value}</value></property>";
        local escapedEntry=$(echo $entry | sed 's/\//\\\//g');

        echo -e "${green} - Setting $name=$value${reset_font}";
        sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path;

    done;
};


function configure_envfile() {

    local path=$1;
    local -n envArray=$2;

    local name;
    local value;

    echo -e "${cyan_b}Configuring ${path}${reset_font}";

    for c in "${envArray[@]}"; do

        name=${c};
        value=${!c};

        if [[ -n ${value} ]]; then
            echo -e "${green} - Setting ${name}=${value}${reset_font}";
            echo -e "\nexport ${name}=${value}" | tee -a ${path} > /dev/null;
        fi;
    
    done;
};


if ! [ -z ${HADOOP_PID_DIR+x} ]; then
    mkdir -p ${HADOOP_PID_DIR};
    echo -e "${green}HADOOP_PID_DIR=${HADOOP_PID_DIR}${reset_font}";
fi;

if ! [ -z ${HADOOP_LOG_DIR+x} ]; then
    mkdir -p ${HADOOP_LOG_DIR};
    echo -e "${green}HADOOP_LOG_DIR=${HADOOP_LOG_DIR}${reset_font}";
fi;


if ! [ -z ${HADOOP_CONF_DIR+x} ]; then
    
    configure_conffile ${HADOOP_CONF_DIR}/core-site.xml CORE_CONF;
    configure_conffile ${HADOOP_CONF_DIR}/hdfs-site.xml HDFS_CONF;
    configure_conffile ${HADOOP_CONF_DIR}/yarn-site.xml YARN_CONF;
    configure_conffile ${HADOOP_CONF_DIR}/httpfs-site.xml HTTPFS_CONF;
    configure_conffile ${HADOOP_CONF_DIR}/kms-site.xml KMS_CONF;
    configure_conffile ${HADOOP_CONF_DIR}/mapred-site.xml MAPRED_CONF;

fi

if ! [ -z ${HADOOP_CONF_DIR+x} ]; then

    declare -a HadoopEnv=(
        # Generic settings for HADOOP 
        "JAVA_HOME" "HADOOP_HOME" "HADOOP_CONF_DIR" "HADOOP_HEAPSIZE_MAX" 
        "HADOOP_HEAPSIZE_MIN" "HADOOP_JAAS_DEBUG" "HADOOP_OPTS" "HADOOP_CLIENT_OPTS" 
        "HADOOP_CLASSPATH" "HADOOP_USER_CLASSPATH_FIRST" "HADOOP_USE_CLIENT_CLASSLOADER" 
        "HADOOP_CLIENT_CLASSLOADER_SYSTEM_CLASSES" "HADOOP_OPTIONAL_TOOLS"
        # Options for remote shell connectivity
        "HADOOP_SSH_OPTS" "HADOOP_SSH_PARALLEL" "HADOOP_WORKERS"
        # Options for all daemons
        "HADOOP_LOG_DIR" "HADOOP_IDENT_STRING" "HADOOP_STOP_TIMEOUT" "HADOOP_PID_DIR" 
        "HADOOP_ROOT_LOGGER" "HADOOP_DAEMON_ROOT_LOGGER" "HADOOP_SECURITY_LOGGER" 
        "HADOOP_NICENESS" "HADOOP_POLICYFILE" "HADOOP_GC_SETTINGS"
        # Secure/privileged execution
        "JSVC_HOME" "HADOOP_SECURE_PID_DIR" "HADOOP_SECURE_LOG" "HADOOP_SECURE_IDENT_PRESERVE"
        # NameNode specific parameters
        "HDFS_AUDIT_LOGGER" "HDFS_NAMENODE_OPTS"
        # SecondaryNameNode specific parameters
        "HDFS_SECONDARYNAMENODE_OPTS"
        # DataNode specific parameters
        "HDFS_DATANODE_OPTS" "HDFS_DATANODE_SECURE_USER" "HDFS_DATANODE_SECURE_EXTRA_OPTS"
        # NFS3 Gateway specific parameters
        "HDFS_NFS3_OPTS" "HDFS_PORTMAP_OPTS" "HDFS_NFS3_SECURE_EXTRA_OPTS" "HDFS_NFS3_SECURE_USER"
        # ZKFailoverController specific parameters
        "HDFS_ZKFC_OPTS"
        # QuorumJournalNode specific parameters
        "HDFS_JOURNALNODE_OPTS"
        # HDFS Balancer specific parameters
        "HDFS_BALANCER_OPTS"
        # HDFS Mover specific parameters
        "HDFS_MOVER_OPTS" "HDFS_DFSROUTER_OPTS"
        # HDFS StorageContainerManager specific parameters
        "HDFS_STORAGECONTAINERMANAGER_OPTS"
        # Advanced Users Only!
        "HADOOP_ENABLE_BUILD_PATHS" "HDFS_NAMENODE_USER"
    );

    configure_envfile ${HADOOP_CONF_DIR}/hadoop-env.sh HadoopEnv;

fi

echo -e "${blue_b}Hadoop-node configuration completed!${reset_font}";
