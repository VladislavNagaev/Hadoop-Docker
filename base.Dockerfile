# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 ubuntu:22.04

LABEL maintainer="Vladislav Nagaev <nagaew.vladislav@yandex.ru>"

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ARG \
    # Задание переменных пользователя
    user=user \
    uid=707 \
    gid=user-group \
    # Задание версий сервисов
    JAVA_VERSION=11 \
    HADOOP_VERSION=3.3.4

ENV \
    # Задание директории домашнего каталога
    HOME=/home/${user} \
    # Задание версий сервисов
    JAVA_VERSION=${JAVA_VERSION} \
    HADOOP_VERSION=${HADOOP_VERSION} \
    # Полные наименования сервисов
    HADOOP_NAME=hadoop-${HADOOP_VERSION} \
    # URL-адреса для скачивания
    HADOOP_URL=https://downloads.apache.org/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    # Директория пользовательских приложений
    APPS_HOME=/opt \
    # Задание домашних директорий
    JAVA_HOME=/usr/lib/jvm/java \
    PYSPARK_PYTHON=/usr/bin/python3 \
    HADOOP_HOME=${APPS_HOME}/hadoop \
    HADOOP_CONF_DIR=/etc/hadoop \
    # Переменные окружения для Python (не создавать файлы кэша .pyc, не помещать в буфер потоки stdout и stderr)
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Выбор time zone
    TZ=Europe/Moscow \
    # Обновление переменных путей
    PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HOME}/.local/bin \
    # Рабочая директория 
    WORK_DIRECTORY=/workspace \
    # Директория логов
    LOG_DIRECTORY=/tmp/logs

RUN \
    # --------------------------------------------------------------------------
    # Базовая настройка операционной системы
    # --------------------------------------------------------------------------
    # Создание домашней директории
    mkdir -p ${HOME} && \
    # Создание группы и отдельного пользователя в ней
    groupadd ${gid} && \
    useradd --system --create-home --home-dir ${HOME} --shell /bin/bash --gid ${gid} --groups sudo --uid ${uid} ${user} && \
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
    # Установка Python 3.10
    # --------------------------------------------------------------------------
    # Добавление условия для добавления настраиваемых PPA
    apt install -y software-properties-common -y && \
    # Добавление (deadsnakes / ppa) в список источников диспетчера пакетов APT
    add-apt-repository ppa:deadsnakes/ppa -y && \
    # Обновление путей
    apt -y update && \
    # Уствнока Python 3.10
    echo Y | apt install -y python3.10 && \
    # Создание символической ссылки на Python 3.10
    ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
    # Установка заголовков разработки для сборки расширений C
    echo Y | apt install -y python3.10-dev && \
    # Установка модуля стандартной библиотеки
    echo Y | apt install -y python3.10-distutils && \
    # Установка утилиты (2to3.11), а также модуля стандартной библиотеки (lib2to3):
    echo Y | apt install -y python3.10-lib2to3 && \
    # Установка модуля стандартной библиотеки (dbm.gnu):
    echo Y | apt install -y python3.10-gdbm && \
    # Установка pip3.10
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    # Обновление pip3.10
    python3.10 -m pip install --upgrade pip && \
    # Установка дополнительных инструментов
    echo Y | apt install -y libpq-dev build-essential libssl-dev libffi-dev python3-dev && \
    # Обновление путей
    apt -y update && \
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
    # Рабочая директория Apache Hadoop
    mkdir -p ${HADOOP_HOME}/logs && \
    chmod a+rwx ${HADOOP_HOME} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Обновление всех пакетов
    # --------------------------------------------------------------------------
    # Обновление путей
    apt -y update && \
    # Обновление пакетов
    echo Y | apt upgrade && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Подготовка директорий
    # --------------------------------------------------------------------------
    # Директория логов
    mkdir -p ${LOG_DIRECTORY} && \
    chmod a+w ${LOG_DIRECTORY} && \
    # Рабочая директория
    mkdir -p ${WORK_DIRECTORY} && \
    chown -R ${user}:${gid} ${WORK_DIRECTORY} && \
    chmod a+rwx ${WORK_DIRECTORY} && \
    # Выбор рабочей директории
    cd ${WORK_DIRECTORY}

ENV \
    # Выбор языкового пакета
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Выбор рабочей директории
# WORKDIR ${WORK_DIRECTORY}

# Копирование файлов проекта
COPY ./entrypoint /entrypoint
COPY ./setting-templates /setting-templates

# Изменение рабочего пользователя
# USER ${user}

# Точка входа
CMD ["/bin/bash", "/entrypoint/base.sh"]
