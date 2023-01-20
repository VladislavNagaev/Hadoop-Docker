# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 ubuntu-base:22.04

LABEL maintainer="Vladislav Nagaev <vladislav.nagaew@gmail.com>"

ENV \ 
    # Задание версий сервисов
    HADOOP_VERSION=3.3.4

ENV \
    # Задание домашних директорий
    HADOOP_HOME=${APPS_HOME}/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    # Полные наименования сервисов
    HADOOP_NAME=hadoop-${HADOOP_VERSION}

ENV \
    # URL-адреса для скачивания
    HADOOP_URL=https://downloads.apache.org/hadoop/core/${HADOOP_NAME}/${HADOOP_NAME}.tar.gz \
    # Обновление переменных путей
    PATH=${PATH}:${HADOOP_HOME}/bin

RUN \
    # --------------------------------------------------------------------------
    # Установка Apache Hadoop
    # --------------------------------------------------------------------------
    # Скачивание GPG-ключа
    curl -O https://downloads.apache.org/hadoop/core/KEYS && \
    # Установка gpg-ключа
    gpg --import KEYS && \
    # Скачивание архива Apache Hadoop
    curl --fail --show-error --location ${HADOOP_URL} --output /tmp/${HADOOP_NAME}.tar.gz && \
    # Скачивание PGP-ключа
    curl --fail --show-error --location ${HADOOP_URL}.asc --output /tmp/${HADOOP_NAME}.tar.gz.asc && \
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
    chmod -R a+rwx ${HADOOP_HOME}
    # --------------------------------------------------------------------------


# Копирование файлов проекта
COPY ./entrypoint /entrypoint/

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint/hadoop-entrypoint.sh"]
CMD []
