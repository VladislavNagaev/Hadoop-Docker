FROM --platform=linux/amd64 debian:12-slim

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

USER root

WORKDIR /

ENV \ 
    # Задание переменных пользователя
    USER=admin \
    UID=1001 \
    GROUP=admin \
    GID=1001 \
    GROUPS="admin,root" \
    PASSWORD=admin \
    # Выбор time zone
    DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Moscow \
    # Задание версий сервисов
    JAVA_VERSION=8 \
    CMAKE_VERSION=3.19 \
    CMAKE_VERSION_FULL=3.19.0 \
    PROTOBUF_VERSION=3.7.1 \
    BOOST_VERSION=1.72.0 \
    BOOST_VERSION_STR=1_72_0 \
    HADOOP_VERSION=3.3.4 \
    # Задание директорий 
    WORK_DIRECTORY=/workspace \
    LOG_DIRECTORY=/tmp/logs \
    ENTRYPOINT_DIRECTORY=/entrypoint \
    # Задание домашних директорий
    JAVA_HOME=/usr/lib/jvm/java \
    PROTOBUF_HOME=/usr/lib/protobuf \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop

ENV \
    # Задание домашних директорий
    HOME=/home/${USER} \
    # Обновление переменных путей
    PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin \
    # Полные наименования сервисов
    CMAKE_NAME=cmake-${CMAKE_VERSION_FULL} \
    PROTOBUF_NAME=protobuf-${PROTOBUF_VERSION} \
    BOOST_NAME=boost_${BOOST_VERSION_STR} \
    HADOOP_NAME=hadoop-${HADOOP_VERSION} \
    HADOOP_SOURCE_NAME=hadoop-rel-release-${HADOOP_VERSION} \
    # URL-адреса для скачивания
    CMAKE_URL=https://cmake.org/files/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION_FULL}.tar.gz \
    PROTOBUF_URL=https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-java-${PROTOBUF_VERSION}.tar.gz \
    BOOST_URL=https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_STR}.tar.gz/download \
    HADOOP_URL=https://github.com/apache/hadoop/archive/refs/tags/rel/release-${HADOOP_VERSION}.tar.gz

RUN \
    # --------------------------------------------------------------------------
    # Базовая настройка операционной системы
    # --------------------------------------------------------------------------
    # Установка пароль пользователя root 
    echo "root:root" | chpasswd && \
    # Создание группы и назначение пользователя в ней
    groupadd --gid ${GID} --non-unique ${GROUP} && \
    useradd --system --create-home --home-dir ${HOME} --shell /bin/bash --gid ${GID} --groups ${GROUPS} --uid ${UID} --password ${PASSWORD} ${USER} && \
    # useradd --system --create-home --home-dir ${HOME} --shell /bin/bash \
    # --gid ${GID} --groups ${GROUPS} --uid ${UID} ${USER} \
    # --password $(perl -e 'print crypt($ARGV[0], "password")' ${PASSWORD})  && \
    # Обновление ссылок
    echo "deb http://deb.debian.org/debian/ sid main" >> /etc/apt/sources.list && \
    # Обновление путей
    apt --yes update && \
    # Установка timezone
    apt install --no-install-recommends --yes tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    # Установка языкового пакета
    apt install --no-install-recommends --yes locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Подготовка директорий
    # --------------------------------------------------------------------------
    # Директория логов
    mkdir -p ${LOG_DIRECTORY} && \
    chown -R ${USER}:${GID} ${LOG_DIRECTORY} && \
    chmod -R a+rw ${LOG_DIRECTORY} && \
    # Рабочая директория
    mkdir -p ${WORK_DIRECTORY} && \
    chown -R ${USER}:${GID} ${WORK_DIRECTORY} && \
    chmod -R a+rwx ${WORK_DIRECTORY} && \
    # Директория entrypoint
    mkdir -p ${ENTRYPOINT_DIRECTORY} && \
    chown -R ${USER}:${GID} ${ENTRYPOINT_DIRECTORY} && \
    chmod -R a+rx ${ENTRYPOINT_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка базовых пакетов
    # --------------------------------------------------------------------------
    apt install --no-install-recommends --yes software-properties-common && \
    apt install --no-install-recommends --yes apt-utils && \
    apt install --no-install-recommends --yes curl && \
    apt install --no-install-recommends --yes netcat-openbsd && \
    apt install --no-install-recommends --yes make && \
    apt install --no-install-recommends --yes autoconf && \
    apt install --no-install-recommends --yes automake && \
    apt install --no-install-recommends --yes git && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Java
    # --------------------------------------------------------------------------
    # Install OpenJDK
    apt install --yes openjdk-${JAVA_VERSION}-jdk && \ 
    # Создание символической ссылки на Java
    ln -s ${JAVA_HOME}-${JAVA_VERSION}-openjdk-amd64 ${JAVA_HOME} && \
    # Smoke test
    java -version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Подготовка shell-скриптов
    # --------------------------------------------------------------------------
    # Ожидание запуска сервиса
    echo \
'''#!/bin/bash \n\
function wait_for_it() { \n\
    local serviceport=$1 \n\
    local service=${serviceport%%:*} \n\
    local port=${serviceport#*:} \n\
    local retry_seconds=5 \n\
    local max_try=100 \n\
    let i=1 \n\
    nc -z $service $port \n\
    result=$? \n\
    until [ $result -eq 0 ]; do \n\
      echo "[$i/$max_try] check for ${service}:${port}..." \n\
      echo "[$i/$max_try] ${service}:${port} is not available yet" \n\
      if (( $i == $max_try )); then \n\
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/" \n\
        exit 1 \n\
      fi \n\
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..." \n\
      let "i++" \n\
      sleep $retry_seconds \n\
      nc -z $service $port \n\
      result=$? \n\
    done \n\
    echo "[$i/$max_try] $service:${port} is available." \n\
} \n\
for i in ${SERVICE_PRECONDITION[@]} \n\
do \n\
    wait_for_it ${i} \n\
done \n\
''' > ${ENTRYPOINT_DIRECTORY}/wait_for_it.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/wait_for_it.sh && \
    # Сборка CMake
    echo \
'''#!/bin/bash \n\
CMAKE_SOURCE_PATH="${1:-}" \n\
echo "CMake building started ..." \n\
owd="$(pwd)" \n\
cd ${CMAKE_SOURCE_PATH} \n\
./bootstrap \n\
make --jobs=$(nproc) \n\
make install \n\
cd "${owd}" \n\
echo "CMake building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/cmake-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/cmake-building.sh && \
    # Сборка ProtocolBuffer
    echo \
'''#!/bin/bash \n\
PROTOBUF_SOURCE_PATH="${1:-}" \n\
echo "Protobuf building started ..." \n\
owd="$(pwd)" \n\
cd ${PROTOBUF_SOURCE_PATH} \n\
./configure --prefix=/usr \n\
make --jobs=$(nproc) \n\
make install \n\
cd "${owd}" \n\
echo "Protobuf building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/protobuf-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/protobuf-building.sh && \
    # Сборка Boost
    echo \
'''#!/bin/bash \n\
BOOST_SOURCE_PATH="${1:-}" \n\
echo "Boost building started ..." \n\
owd="$(pwd)" \n\
cd ${BOOST_SOURCE_PATH} \n\
./bootstrap.sh --prefix=/usr/ \n\
./b2 --without-python \n\
./b2 --without-python install \n\
cd "${owd}" \n\
echo "Boost building completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/boost-building.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/boost-building.sh && \
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
    # Удаление CMake
    echo \
'''#!/bin/bash \n\
CMAKE_SOURCE_PATH="${1:-}" \n\
echo "CMake unistalling started ..." \n\
owd="$(pwd)" \n\
cd ${CMAKE_SOURCE_PATH} \n\
make uninstall \n\
cd "${owd}" \n\
echo "CMake unistalling completed!" \n\
''' > ${ENTRYPOINT_DIRECTORY}/cmake-uninstalling.sh && \
    cat ${ENTRYPOINT_DIRECTORY}/cmake-uninstalling.sh && \
    # Удаление ProtocolBuffer
    echo \
'''#!/bin/bash \n\
PROTOBUF_SOURCE_PATH="${1:-}" \n\
echo "Protobuf unistalling started ..." \n\
owd="$(pwd)" \n\
cd ${PROTOBUF_SOURCE_PATH} \n\
make uninstall \n\
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
    # Установка обязательных пакетов
    # --------------------------------------------------------------------------
    # Zlib devel
    apt install --no-install-recommends --yes zlib1g-dev && \
    # openssl devel
    apt install --no-install-recommends --yes libssl-dev && \
    # Cyrus SASL devel
    apt install --no-install-recommends --yes libsasl2-dev && \
    # GNU
    apt install --no-install-recommends --yes libtool && \
    apt install --no-install-recommends --yes pkg-config && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Maven
    # --------------------------------------------------------------------------
    apt install --no-install-recommends --yes maven>=3.3 && \
    # Smoke test
    mvn --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка GCC 9.3.0
    # --------------------------------------------------------------------------
    # add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    # apt --yes update && \
    apt install --no-install-recommends --yes g++-9 && \
    apt install --no-install-recommends --yes gcc-9 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9 && \
    # Smoke test
    gcc --version && \
    g++ --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка CMake
    # --------------------------------------------------------------------------
    # Скачивание архива
    curl --fail --show-error --location ${CMAKE_URL} --output /tmp/${CMAKE_NAME}.tar.gz && \
    # Распаковка архива в рабочую папку
    tar -xf /tmp/${CMAKE_NAME}.tar.gz -C /tmp/ && \
    # Удаление исходного архива
    rm /tmp/${CMAKE_NAME}.tar.gz* && \
    # Сборка CMake
    "${ENTRYPOINT_DIRECTORY}/cmake-building.sh" /tmp/${CMAKE_NAME} && \
    # Smoke test
    cmake --version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка ProtocolBuffer
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
    # Установка Boost
    # --------------------------------------------------------------------------
    # Скачивание архива
    curl --fail --show-error --location ${BOOST_URL} --output /tmp/${BOOST_NAME}.tar.gz && \
    # Распаковка архива в рабочую папку
    tar -xf /tmp/${BOOST_NAME}.tar.gz -C /tmp/ && \
    # Удаление исходного архива
    rm /tmp/${BOOST_NAME}.tar.gz* && \
    # Сборка Boost
    "${ENTRYPOINT_DIRECTORY}/boost-building.sh" /tmp/${BOOST_NAME} && \
    # Удаление исходного кода
    rm --recursive /tmp/${BOOST_NAME} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Snappy compression
    # --------------------------------------------------------------------------
    # apt install --no-install-recommends --yes ubuntu-snappy && \
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
    # Bug fix https://github.com/eirslett/frontend-maven-plugin/issues/757
    sed -i s/$\{nodejs.version\}/v14.0.0/g /tmp/${HADOOP_SOURCE_NAME}/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/hadoop-yarn-applications-catalog/hadoop-yarn-applications-catalog-webapp/pom.xml && \
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
    chown -R ${USER}:${GID} ${HADOOP_HOME} && \
    chmod -R a+rwx ${HADOOP_HOME} && \
    # Smoke test
    hadoop version && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Удаление неактуальных пакетов, директорий, очистка кэша
    # --------------------------------------------------------------------------
    # Удаление Maven
    apt remove --yes maven && \
    # Удаление GCC 9.3.0
    apt remove --yes g++-9 && \
    apt remove --yes gcc-9 && \
    # Удаление CMake
    "${ENTRYPOINT_DIRECTORY}/cmake-uninstalling.sh" /tmp/${CMAKE_NAME} && \
    # Удаление исходного кода CMake
    rm --recursive /tmp/${CMAKE_NAME} && \
    # Удаление ProtocolBuffer
    "${ENTRYPOINT_DIRECTORY}/protobuf-uninstalling.sh" /tmp/${PROTOBUF_NAME} && \
    # Удаление исходного кода ProtocolBuffer
    rm --recursive /tmp/${PROTOBUF_NAME} && \
    # Удаление Boost
    rm --force /usr/lib/libboost_* && \
    rm --recursive --force /usr/include/boost && \
    # Удаление кэш Apache Hadoop
    rm --recursive /root/.m2/repository && \
    # Удаление неиспользуемых пакетов
    apt remove --yes software-properties-common && \
    apt remove --yes curl && \
    apt remove --yes make && \
    apt remove --yes autoconf && \
    apt remove --yes automake && \
    apt remove --yes git && \
    apt remove --yes zlib1g-dev && \
    apt remove --yes libsasl2-dev && \
    apt remove --yes libtool && \
    apt remove --yes pkg-config && \
    # Общая очистка
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
