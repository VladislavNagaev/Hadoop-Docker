# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 ubuntu-base:16.04

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ENV \ 
    # Задание версий сервисов
    PROTOBUF_VERSION=2.5.0 \
    HADOOP_VERSION=3.2.1

ENV \
    # Задание домашних директорий
    PROTOBUF_HOME=/usr/lib/protobuf \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    # Полные наименования сервисов
    PROTOBUF_NAME=protobuf-${PROTOBUF_VERSION} \
    HADOOP_NAME=hadoop-${HADOOP_VERSION} \
    HADOOP_SOURCE_NAME=hadoop-rel-release-${HADOOP_VERSION}

ENV \
    # URL-адреса для скачивания
    PROTOBUF_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/${PROTOBUF_NAME}.tar.gz \
    HADOOP_URL=https://github.com/apache/hadoop/archive/refs/tags/rel/release-${HADOOP_VERSION}.tar.gz \
    # Обновление переменных путей
    PATH=${HADOOP_HOME}/bin:${PATH}

RUN \
    # --------------------------------------------------------------------------
    # Подготовка shell-скриптов
    # --------------------------------------------------------------------------
    # Сборка protobuf
    echo \
'''#!/bin/bash \n\
PROTOBUF_SOURCE_PATH="${1:-}" \n\
echo "Protobuf building started ..." \n\
owd="$(pwd)" \n\
cd ${PROTOBUF_SOURCE_PATH} \n\
./autogen.sh \n\
./configure --prefix=/usr \n\
make --jobs=$(nproc --all) \n\
make --jobs=$(nproc --all) install \n\
cd "${owd}" \n\
echo "Protobuf building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/protobuf-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/protobuf-building.sh && \
    # Сборка hadoop
    echo \
'''#!/bin/bash \n\
HADOOP_SOURCE_PATH="${1:-}" \n\
echo "Hadoop building started ..." \n\
owd="$(pwd)" \n\
cd ${HADOOP_SOURCE_PATH} \n\
mvn package -Pdist,native -DskipTests -Dtar \n\
cd "${owd}" \n\
echo "Hadoop building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/hadoop-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/hadoop-building.sh && \
    # Удаление protobuf
    echo \
'''#!/bin/bash \n\
PROTOBUF_SOURCE_PATH="${1:-}" \n\
echo "Protobuf unistalling started ..." \n\
owd="$(pwd)" \n\
cd ${PROTOBUF_SOURCE_PATH} \n\
make --jobs=$(nproc --all) uninstall \n\
cd "${owd}" \n\
echo "Protobuf uninstalling completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/protobuf-uninstalling.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/protobuf-uninstalling.sh && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Настройка прав доступа скопированных файлов/директорий
    # --------------------------------------------------------------------------
    # Директория/файл entrypoint
    chown -R ${USER}:${GID} ${ENTRYPOINT_DIRECTORY} && \
    chmod -R a+x ${ENTRYPOINT_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка базовых пакетов
    # --------------------------------------------------------------------------
    # Обновление путей
    apt --yes update && \
    apt install --no-install-recommends --yes build-essential && \
    apt install --no-install-recommends --yes autoconf && \
    apt install --no-install-recommends --yes automake && \
    apt install --no-install-recommends --yes libtool && \
    apt install --no-install-recommends --yes cmake && \
    apt install --no-install-recommends --yes zlib1g-dev && \
    apt install --no-install-recommends --yes pkg-config && \
    apt install --no-install-recommends --yes libssl-dev && \
    apt install --no-install-recommends --yes libsasl2-dev && \
    apt install --no-install-recommends --yes netcat && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Maven
    # --------------------------------------------------------------------------
    apt install --no-install-recommends --yes maven && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка ProtocolBuffer 2.5.0
    # --------------------------------------------------------------------------
    # Скачивание архива
    curl --fail --show-error --location ${PROTOBUF_URL} --output /tmp/${PROTOBUF_NAME}.tar.gz && \
    # Распаковка архива в рабочую папку
    tar -xf /tmp/${PROTOBUF_NAME}.tar.gz -C /tmp/ && \
    # Удаление исходного архива
    rm /tmp/${PROTOBUF_NAME}.tar.gz* && \
    # Сборка Protobuf
    "${ENTRYPOINT_DIRECTORY}/protobuf-building.sh" /tmp/${PROTOBUF_NAME} && \
    # Smoke test
    protoc --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Snappy compression
    # --------------------------------------------------------------------------
    apt install --no-install-recommends --yes snappy && \
    apt install --no-install-recommends --yes libsnappy-dev && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Bzip2
    # --------------------------------------------------------------------------
    apt install --no-install-recommends --yes bzip2 && \
    apt install --no-install-recommends --yes libbz2-dev && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Hadoop
    # --------------------------------------------------------------------------
    # Скачивание архива с исходным кодом Apache Hadoop из ветки master
    curl --fail --show-error --location ${HADOOP_URL} --output /tmp/${HADOOP_SOURCE_NAME}.tar.gz && \
    # Распаковка архива с исходным кодом Apache Hadoop в рабочую папку
    tar -xvf /tmp/${HADOOP_SOURCE_NAME}.tar.gz -C /tmp/ && \
    # Удаление исходного архива
    rm /tmp/${HADOOP_SOURCE_NAME}.tar.gz* && \
    # Сборка Apache Hadoop
    "${ENTRYPOINT_DIRECTORY}/hadoop-building.sh" /tmp/${HADOOP_SOURCE_NAME} && \
    # Перемещение собранного Apache Hadoop в домашнюю директорию
    mv /tmp/${HADOOP_SOURCE_NAME}/hadoop-dist/target/${HADOOP_NAME} $(dirname ${HADOOP_HOME})/ && \
    # Удаление исходного кода
    rm --recursive /tmp/${HADOOP_SOURCE_NAME} && \
    # Создание символической ссылки на Apache Hadoop
    ln -s $(dirname ${HADOOP_HOME})/${HADOOP_NAME} ${HADOOP_HOME} && \
    # Создание символической ссылки на HADOOP_CONF_DIR
    mkdir -p ${HADOOP_HOME}/etc/hadoop && \
    ln -s ${HADOOP_HOME}/etc/hadoop ${HADOOP_CONF_DIR} && \
    chown -R ${USER}:${GID} ${HADOOP_CONF_DIR} && \
    chmod -R a+rw ${HADOOP_CONF_DIR} && \
    # Рабочая директория Apache Hadoop
    mkdir -p ${HADOOP_HOME}/logs && \
    chown -R ${USER}:${GID} ${HADOOP_HOME} && \
    chmod -R a+rwx ${HADOOP_HOME} && \
    # Smoke test
    hadoop version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Удаление неактуальных пакетов, директорий, очистка кэша
    # --------------------------------------------------------------------------
    apt remove --yes maven && \
    "${ENTRYPOINT_DIRECTORY}/protobuf-uninstalling.sh" /tmp/${PROTOBUF_NAME} && \
    rm --recursive  /tmp/${PROTOBUF_NAME} && \
    rm --recursive  /root/.m2/repository && \
    apt --yes autoremove && \
    rm --recursive --force /var/lib/apt/lists/*
    # --------------------------------------------------------------------------

# Копирование файлов проекта
COPY ./entrypoint ${ENTRYPOINT_DIRECTORY}/

# Выбор рабочей директории
WORKDIR ${WORK_DIRECTORY}

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint/hadoop-entrypoint.sh"]
CMD []
