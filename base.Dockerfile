# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 ubuntu:22.04

LABEL maintainer="Vladislav Nagaev <nagaew.vladislav@yandex.ru>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ENV \ 
    # Задание переменных пользователя
    USER=root \
    UID=0 \
    GROUP=hadoop \
    GID=1001 \
    GROUPS="root,hadoop" \
    # Выбор time zone
    TZ=Europe/Moscow \
    # Директория пользовательских приложений
    APPS_HOME=/opt \
    # Задание версий сервисов
    JAVA_VERSION=11 \
    HADOOP_VERSION=3.3.4

ENV \
    # Задание домашних директорий
    JAVA_HOME=/usr/lib/jvm/java \
    HADOOP_HOME=${APPS_HOME}/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    # Полные наименования сервисов
    HADOOP_NAME=hadoop-${HADOOP_VERSION}

ENV \
    # URL-адреса для скачивания
    HADOOP_URL=https://downloads.apache.org/hadoop/core/${HADOOP_NAME}/${HADOOP_NAME}.tar.gz \
    # Обновление переменных путей
    PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin \
    # Рабочая директория 
    WORK_DIRECTORY=/workspace \
    # Директория логов
    LOG_DIRECTORY=/tmp/logs

RUN \
    # --------------------------------------------------------------------------
    # Базовая настройка операционной системы
    # --------------------------------------------------------------------------
    # Создание группы и назначение пользователя в ней
    groupadd --gid ${GID} --non-unique ${GROUP} && \
    usermod --append --groups ${GROUPS} ${USER} && \
    # Обновление путей
    apt -y update && \
    # Установка timezone
    apt install -y tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    # Установка языкового пакета
    apt install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка базовых пакетов
    # --------------------------------------------------------------------------
    echo Y | apt install -y curl && \
    echo Y | apt install -y wget && \
    apt install -y unzip && \
    apt install -y ssh && \
    apt install -y pdsh && \
    apt install -y gettext-base && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка C compiler (GCC)
    # --------------------------------------------------------------------------
    echo Y | apt install -y build-essential && \
    apt install -y manpages-dev && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Java
    # --------------------------------------------------------------------------
    # Install OpenJDK
    apt install -y openjdk-${JAVA_VERSION}-jdk && \
    # Install Apache Ant
    apt install -y ant && \
    # Создание символической ссылки на Java
    ln -s /usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 /usr/lib/jvm/java && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка Apache Hadoop
    # --------------------------------------------------------------------------
    # Скачивание GPG-ключа
    curl -O https://downloads.apache.org/hadoop/core/KEYS && \
    # Установка gpg-ключа
    gpg --import KEYS && \
    # Скачивание архива Apache Hadoop
    curl -fSL ${HADOOP_URL} -o /tmp/${HADOOP_NAME}.tar.gz && \
    # Скачивание PGP-ключа
    curl -fSL ${HADOOP_URL}.asc -o /tmp/${HADOOP_NAME}.tar.gz.asc && \
    # Верификация ключа шифрования
    gpg --verify /tmp/${HADOOP_NAME}.tar.gz.asc && \
    # Распаковка архива Apache Hadoop в рабочую папку
    tar -xvf /tmp/${HADOOP_NAME}.tar.gz -C ${APPS_HOME}/ && \
    # Удаление исходного архива и ключа шифрования
    rm /tmp/${HADOOP_NAME}.tar* && \
    # Создание символической ссылки на Apache Hadoop
    ln -s ${APPS_HOME}/${HADOOP_NAME} ${HADOOP_HOME} && \
    # Создание символической ссылки на HADOOP_CONF_DIR
    ln -s ${HADOOP_HOME}/etc/hadoop ${HADOOP_CONF_DIR} && \
    chown -R ${USER}:${GID} ${HADOOP_CONF_DIR} && \
    chmod -R a+rw ${HADOOP_CONF_DIR} && \
    # Рабочая директория Apache Hadoop
    mkdir -p ${HADOOP_HOME}/logs && \
    chown -R ${USER}:${GID} ${HADOOP_HOME} && \
    chmod -R a+rwx ${HADOOP_HOME} && \
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
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Очистка кэша
    # --------------------------------------------------------------------------
    rm -rf /var/lib/apt/lists/*
    # --------------------------------------------------------------------------

ENV \
    # Выбор языкового пакета
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Копирование файлов проекта
COPY ./entrypoint /entrypoint
COPY ./setting-templates /setting-templates

RUN \
    # Директория entrypoint
    chown -R ${USER}:${GID} /entrypoint && \
    chmod -R a+x entrypoint && \
    # Директория setting-templates
    chown -R ${USER}:${GID} /setting-templates && \
    chmod -R a+rw setting-templates

# Точка входа
CMD ["/bin/bash", "/entrypoint/base.sh"]
