# Hadoop Docker

Hadoop Docker image built on top of [ubuntu-base:18.04](https://github.com/VladislavNagaev/Ubuntu-Docker.git)

## Quick Start

Build image:
~~~
make --file Makefile 
~~~

Depoyment of containers:
~~~
docker-compose -f docker-compose.yaml up -d
~~~


## Interfaces:
---
* [Hadoop WebUi](http://127.0.0.1:9870/explorer.html#/)


## Technologies
---
Project is created with:
* Apache Hadoop version: 3.3.4
* Docker verion: 20.10.22
* Docker-compose version: v2.11.1

___
Project Organization
---

    ├── README.md
    │
    ├── entrypoint  
    │   ├── hadoop-entrypoint.sh
    │   ├── hadoop-configure.sh 
    │   ├── hadoop-initialization.sh
    │   └── hadoop-wait_for_it.sh 
    │ 
    ├── docker-compose.yaml
    ├── base.Dockerfile
    ├── Makefile
    ├── hadoop.env
    ├── .dockerignore
    └── .gitignore

---