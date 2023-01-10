# Образ на основе которого будет создан контейнер
FROM hadoop-base:latest

LABEL maintainer="Vladislav Nagaev <nagaew.vladislav@yandex.ru>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ARG \
    # Переменные CORE
    CORE_CONF_fs_defaultFS \
    CORE_CONF_hadoop_proxyuser_hue_hosts \
    CORE_CONF_hadoop_proxyuser_hue_groups \
    CORE_CONF_io_compression_codecs \
    CORE_CONF_tmp_dir \
    # Переменные HDFS
    HDFS_CONF_dfs_replication \
    HDFS_CONF_dfs_permissions_enabled \
    HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check \
    HDFS_CONF_dfs_namenode_name_path \
    HDFS_CONF_dfs_datanode_data_path \
    HDFS_CONF_dfs_namenode_name_dir \
    HDFS_CONF_dfs_datanode_data_dir \
    HDFS_CONF_dfs_namenode_safemode_extension \
    # Переменные YARN
    YARN_CONF_yarn_log___aggregation___enable \
    YARN_CONF_yarn_log_server_url \
    YARN_CONF_yarn_resourcemanager_recovery_enabled \
    YARN_CONF_yarn_resourcemanager_store_class \
    YARN_CONF_yarn_resourcemanager_scheduler_class \
    YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb \
    YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores \
    YARN_CONF_yarn_resourcemanager_fs_state___store_uri \
    YARN_CONF_yarn_resourcemanager_system___metrics___publisher_enabled \
    YARN_CONF_yarn_resourcemanager_hostname \
    YARN_CONF_yarn_resourcemanager_address \
    YARN_CONF_yarn_resourcemanager_scheduler_address \
    YARN_CONF_yarn_resourcemanager_resource__tracker_address \
    YARN_CONF_yarn_timeline___service_enabled \
    YARN_CONF_yarn_timeline___service_generic___application___history_enabled \
    YARN_CONF_yarn_timeline___service_hostname \
    YARN_CONF_mapreduce_map_output_compress \
    YARN_CONF_mapred_map_output_compress_codec \
    YARN_CONF_yarn_nodemanager_resource_detect___hardware___capabilities \
    YARN_CONF_yarn_nodemanager_resource_memory___mb \
    YARN_CONF_yarn_nodemanager_resource_cpu___vcores \
    YARN_CONF_yarn_nodemanager_disk___health___checker_max___disk___utilization___per___disk___percentage \
    YARN_CONF_yarn_nodemanager_remote___app___log___dir \
    YARN_CONF_yarn_nodemanager_aux___services \
    YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path \
    # Переменные MAPRED
    MAPRED_CONF_mapreduce_framework_name \
    MAPRED_CONF_mapred_child_java_opts \
    MAPRED_CONF_mapreduce_map_memory_mb \
    MAPRED_CONF_mapreduce_reduce_memory_mb \
    MAPRED_CONF_mapreduce_map_java_opts \
    MAPRED_CONF_mapreduce_reduce_java_opts

ENV \
    # Переменные CORE
    CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://hadoop-namenode:9000} \
    CORE_CONF_hadoop_proxyuser_hue_hosts=${CORE_CONF_hadoop_proxyuser_hue_hosts:-*} \
    CORE_CONF_hadoop_proxyuser_hue_groups=${CORE_CONF_hadoop_proxyuser_hue_groups:-*} \
    CORE_CONF_io_compression_codecs=${CORE_CONF_io_compression_codecs:-org.apache.hadoop.io.compress.GzipCodec} \
    CORE_CONF_tmp_dir=${CORE_CONF_tmp_dir:-/hadoop/tmp} \
    CORE_CONF_hadoop_http_staticuser_user=root \
    # Переменные HDFS
    HDFS_CONF_dfs_replication=${HDFS_CONF_dfs_replication:-3} \
    HDFS_CONF_dfs_permissions_enabled=${HDFS_CONF_dfs_permissions_enabled:-false} \
    HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check=${HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check:-false} \
    HDFS_CONF_dfs_namenode_name_path=${HDFS_CONF_dfs_namenode_name_path:-/hadoop/dfs/namenode} \
    HDFS_CONF_dfs_datanode_data_path=${HDFS_CONF_dfs_datanode_data_path:-/hadoop/dfs/datanode} \
    HDFS_CONF_dfs_namenode_name_dir=${HDFS_CONF_dfs_namenode_name_dir:-file:///hadoop/dfs/namenode} \
    HDFS_CONF_dfs_datanode_data_dir=${HDFS_CONF_dfs_datanode_data_dir:-file:///hadoop/dfs/datanode} \
    HDFS_CONF_dfs_namenode_safemode_extension=${HDFS_CONF_dfs_namenode_safemode_extension:-30000} \
    HDFS_CONF_dfs_namenode_rpc___bind___host=0.0.0.0 \
    HDFS_CONF_dfs_namenode_servicerpc___bind___host=0.0.0.0 \
    HDFS_CONF_dfs_namenode_http___bind___host=0.0.0.0 \
    HDFS_CONF_dfs_namenode_https___bind___host=0.0.0.0 \
    HDFS_CONF_dfs_client_use_datanode_hostname=true \
    HDFS_CONF_dfs_datanode_use_datanode_hostname=true \
    # Переменные YARN
    YARN_CONF_yarn_log___aggregation___enable=${YARN_CONF_yarn_log___aggregation___enable:-true}\ 
    YARN_CONF_yarn_log_server_url=${YARN_CONF_yarn_log_server_url:-http://hadoop-historyserver:8188/applicationhistory/logs/}\ 
    YARN_CONF_yarn_resourcemanager_recovery_enabled=${YARN_CONF_yarn_resourcemanager_recovery_enabled:-true}\ 
    YARN_CONF_yarn_resourcemanager_store_class=${YARN_CONF_yarn_resourcemanager_store_class:-org.apache.hadoop.yarn.server.resourcemanager.recovery.FileSystemRMStateStore}\ 
    YARN_CONF_yarn_resourcemanager_scheduler_class=${YARN_CONF_yarn_resourcemanager_scheduler_class:-org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler}\ 
    YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb=${YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb:-8192} \
    YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores=${YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores:-4} \
    YARN_CONF_yarn_resourcemanager_fs_state___store_uri=${YARN_CONF_yarn_resourcemanager_fs_state___store_uri:-/rmstate} \
    YARN_CONF_yarn_resourcemanager_system___metrics___publisher_enabled=${YARN_CONF_yarn_resourcemanager_system___metrics___publisher_enabled:-true} \
    YARN_CONF_yarn_resourcemanager_hostname=${YARN_CONF_yarn_resourcemanager_hostname:-hadoop-resourcemanager} \
    YARN_CONF_yarn_resourcemanager_address=${YARN_CONF_yarn_resourcemanager_address:-hadoop-resourcemanager:8032} \
    YARN_CONF_yarn_resourcemanager_scheduler_address=${YARN_CONF_yarn_resourcemanager_scheduler_address:-hadoop-resourcemanager:8030} \
    YARN_CONF_yarn_resourcemanager_resource__tracker_address=${YARN_CONF_yarn_resourcemanager_resource__tracker_address:-hadoop-resourcemanager:8031} \
    YARN_CONF_yarn_timeline___service_enabled=${YARN_CONF_yarn_timeline___service_enabled:-true} \
    YARN_CONF_yarn_timeline___service_generic___application___history_enabled=${YARN_CONF_yarn_timeline___service_generic___application___history_enabled:-true} \
    YARN_CONF_yarn_timeline___service_hostname=${YARN_CONF_yarn_timeline___service_hostname:-hadoop-historyserver} \
    YARN_CONF_mapreduce_map_output_compress=${YARN_CONF_mapreduce_map_output_compress:-true} \
    YARN_CONF_mapred_map_output_compress_codec=${YARN_CONF_mapred_map_output_compress_codec:-org.apache.hadoop.io.compress.GzipCodec} \
    YARN_CONF_yarn_nodemanager_resource_detect___hardware___capabilities=${YARN_CONF_yarn_nodemanager_resource_detect___hardware___capabilities:-true} \
    YARN_CONF_yarn_nodemanager_resource_memory___mb=${YARN_CONF_yarn_nodemanager_resource_memory___mb:-16384} \
    YARN_CONF_yarn_nodemanager_resource_cpu___vcores=${YARN_CONF_yarn_nodemanager_resource_cpu___vcores:-8} \
    YARN_CONF_yarn_nodemanager_disk___health___checker_max___disk___utilization___per___disk___percentage=${YARN_CONF_yarn_nodemanager_disk___health___checker_max___disk___utilization___per___disk___percentage:-98.5} \
    YARN_CONF_yarn_nodemanager_remote___app___log___dir=${YARN_CONF_yarn_nodemanager_remote___app___log___dir:-/app-logs} \
    YARN_CONF_yarn_nodemanager_aux___services=${YARN_CONF_yarn_nodemanager_aux___services:-mapreduce_shuffle} \
    YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path=${YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path:-/hadoop/yarn/timeline} \
    YARN_CONF_yarn_resourcemanager_bind___host=0.0.0.0 \
    YARN_CONF_yarn_nodemanager_bind___host=0.0.0.0 \
    YARN_CONF_yarn_timeline___service_bind___host=0.0.0.0 \
    # Переменные MAPRED
    MAPRED_CONF_mapreduce_framework_name=${MAPRED_CONF_mapreduce_framework_name:-yarn} \
    MAPRED_CONF_mapred_child_java_opts=${MAPRED_CONF_mapred_child_java_opts:--Xmx4096m} \
    MAPRED_CONF_mapreduce_map_memory_mb=${MAPRED_CONF_mapreduce_map_memory_mb:-4096} \
    MAPRED_CONF_mapreduce_reduce_memory_mb=${MAPRED_CONF_mapreduce_reduce_memory_mb:-8192} \
    MAPRED_CONF_mapreduce_map_java_opts=${MAPRED_CONF_mapreduce_map_java_opts:--Xmx3072m} \
    MAPRED_CONF_mapreduce_reduce_java_opts=${MAPRED_CONF_mapreduce_reduce_java_opts:--Xmx6144m} \
    MAPRED_CONF_yarn_app_mapreduce_am_env="HADOOP_MAPRED_HOME=${APPS_HOME}/hadoop-${HADOOP_VERSION}" \
    MAPRED_CONF_mapreduce_map_env="HADOOP_MAPRED_HOME=${APPS_HOME}/hadoop-${HADOOP_VERSION}" \
    MAPRED_CONF_mapreduce_reduce_env="HADOOP_MAPRED_HOME=${APPS_HOME}/hadoop-${HADOOP_VERSION}" \
    MAPRED_CONF_yarn_nodemanager_bind___host=0.0.0.0

RUN \
    # --------------------------------------------------------------------------
    # Общие настройки
    # --------------------------------------------------------------------------
    # Удаление исходных файлов конфигурации
    rm ${HADOOP_CONF_DIR}/core-site.xml && \
    rm ${HADOOP_CONF_DIR}/hdfs-site.xml && \
    rm ${HADOOP_CONF_DIR}/mapred-site.xml && \
    rm ${HADOOP_CONF_DIR}/yarn-site.xml && \
    # Заполнение шаблонов переменными окружения и перемещение в директорию HADOOP_CONF_DIR
    envsubst < /setting-templates/core-site.xml.template >> ${HADOOP_CONF_DIR}/core-site.xml && \
    envsubst < /setting-templates/hdfs-site.xml.template >> ${HADOOP_CONF_DIR}/hdfs-site.xml && \
    envsubst < /setting-templates/mapred-site.xml.template >> ${HADOOP_CONF_DIR}/mapred-site.xml && \
    envsubst < /setting-templates/yarn-site.xml.template >> ${HADOOP_CONF_DIR}/yarn-site.xml && \
    # Подготовка дирректорий
    mkdir -p ${HDFS_CONF_dfs_namenode_name_path} && \
    mkdir -p ${HDFS_CONF_dfs_datanode_data_path} && \
    mkdir -p ${YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path} && \
    mkdir -p ${YARN_CONF_yarn_resourcemanager_fs_state___store_uri}
