# Project Funkwhale swarm infra

**Created by:** pokerface03

## Table of Contents
- [Editing .bashrc](#editing-bashrc)
- [Preparing manager & workers](#preparing-manager--workers)
  - [funkwhale.neo.yml](#funkwhaleneoyml)
  - [funkwhale.neo.yml.sh](#funkwhaleneoymlsh)
  - [prepare.sh](#preparesh)
- [Configuration files](#configuration-files)
- [Bitnami Cluster](#bitnami-cluster)
- [Docker compose](#docker-compose)

## Editing .bashrc

First, we add the `ansibleplaybook()` function to the `.bashrc` file so we can use it in the preparation bash scripts.

```bash
  # PATH where you have placed the ssh keys
  export keypath=/home/fedlab18/keys
  # PATH where you have the inventory 
  export invpath=/home/fedlab18/fedlab/ansible

ansibleplaybook() {
  docker run -it --rm -v ${keypath}:/keys \
    -v ${invpath}:/inv \
    -v $(pwd):/apps  \
    -w /apps alpine/ansible ansible-playbook "$@"
}
```

## Preparing manager & workers

### funkwhale.neo.yml

* Creating the necessary directories on the workers to host the funkwhale services:

```bash
    volume_main_data_path: "/var/fedlab/funkwhale.fedlab" 
    directories:
      - "data/postgres"
      - "data/redis"
      - "data/typesense/data"
      - "funkwhale/data/music"
      - "funkwhale/data/media"
      - "funkwhale/data/static"
      - "nginx"
      - "ssl"
```

* Adding nginx configuration files to each worker:
  - nginx/funkwhale.conf 
  - nginx/funkwhale_proxy.conf

### funkwhale.neo.yml.sh

Executing the Ansible playbook with the desired parameters for the above YAML file.

```bash
export User="debian"
export dockerUser="fedlab"
export inventoryfile="/inv/inventory" # remember what you set in .bashrc
export inventory="workers"
export projectdiransible="/apps"
export manager_ip="83.212.75.101"
export ANSIBLE_HOST_KEY_CHECKING=False
export YAML="funkwhale-neo.yml"


####################################################
# Definition of bash script prepare.sh variables
###########################
# The user to be used for Docker
export dockeruser="${dockeruser}"
# Funkwhale version
export FUNKWHALE_VERSION="1.4.0"
# Your server's hostname
##########################
export funkwhale_hostname="play.fedlab.xyz"
##########################
# Definition of file paths. Set the PATHsecrets 
##########################
export PATHenv=".."

export funkwhale_env_path="${PATHenv}/.env"
##########################

export funkwhale_env_file="${PATHenv}/env.prod.sample"
export funkwhale_project_dir="$(pwd)"
export nginx_config_dir="$(pwd)"
```

Executing prepare.sh:

```bash
# run prepare.sh
./prepare.sh
```

### prepare.sh

This script takes the `env.prod.sample` and `funkwhale.template` files and based on them creates the `.env` and `funkwhale.conf` files respectively, inserting the appropriate values.



## Configuration files

The **funkwhale.conf** and **funkwhale_proxy.conf** files are used for nginx configuration by the services that will be created.

## Bitnami Cluster

The Bitnami Cluster was used as the PostgreSQL database foundation, so that the data from the funkwhale application services is not lost. Then the services that want to use it need to know its Network and the DATABASE_URL (the general format is shown below).

```bash
DATABASE_URL=postgresql://<username>:<password>@<host>:<port>/<database>
```

## Docker compose

The **docker-compose.yml** file contains all the services that will be deployed to docker swarm. It uses the `.env` file to obtain the variables needed for the services.

Execute:

```bash
docker stack deploy -c docker-compose.yml funkwhale
```
> **IMPORTANT:** This command above must be executed on the manager node of the swarm where the docker-compose.yml file should exist and also the .env file variables should be setted (on the manager)