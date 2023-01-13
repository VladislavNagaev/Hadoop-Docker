# Hadoop Docker

## Quick Start

Prepare docker network:

~~~
sudo ufw enable

sudo ufw allow 2377/tcp && sudo ufw allow 7946/tcp && sudo ufw allow 7946/udp && sudo ufw allow 4789/udp

docker swarm init

docker network create --driver=overlay --attachable main-overlay-network
~~~

Prepare directories for data:
~~~
mkdir -p ~/Apps/hadoop-data/namenode
mkdir -p ~/Apps/hadoop-data/datanode
mkdir -p ~/Apps/hadoop-data/historyserver

mkdir -p ~/Apps/hadoop-workspace
~~~

Depoyment of containers:
~~~
docker-compose -f docker-compose up -d
~~~


## Interfaces:
---
* Hadoop WebUi http://127.0.0.1:9870/explorer.html#/


## Technologies
---
Project is created with:
* Ubuntu verion: 22.04
* Apache Hadoop version: 3.3.4
* Docker verion: 20.10.22
* Docker-compose version: v2.11.1

___
Project Organization
---

    ├── README.md
    │
    ├── postgres  
    │   ├── entrypoint.sh
    │   ├── configure.sh 
    │   ├── initialization.sh
    │   └── wait_for_it.sh 
    │ 
    ├── docker-compose.yaml
    ├── base.Dockerfile
    ├── Makefile
    ├── hadoop.env
    ├── .dockerignore
    └── .gitignore

---