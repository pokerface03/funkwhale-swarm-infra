#!/bin/bash -i

export User="debian"
export dockerUser="fedlab"
export inventoryfile="/inv/inventory" # Ensure this path matches any inventory configuration in .bashrc
export inventory="workers"
export projectdiransible="/apps"
#export TLS_certificate_path="/keys/funkwhale"
#export TLS_key_path="/keys/funkwhale"
export manager_ip="83.212.75.101"
export ANSIBLE_HOST_KEY_CHECKING=False
export YAML="funkwhale-neo.yml"


####################################################
# Define variables for the bash script prepare.sh
###########################
# User to be used for Docker
export dockeruser="${dockerUser}"
# Funkwhale version
export FUNKWHALE_VERSION="1.4.0"
# Server hostname
##########################
export funkwhale_hostname="play.fedlab.xyz"
##########################
# Define file path locations.
##########################
export path_env=".."

#export PATHsecrets="$(pwd)"

export funkwhale_env_path="${path_env}/.env"

# TLS file paths (if any)
#export tls_certificate_path="${PATHsecrets}/funkwhale.crt"
#export tls_key_path="${PATHsecrets}/funkwhale.key"
##########################

export funkwhale_env_file="${path_env}/env.prod.sample"
export funkwhale_project_dir="$(pwd)"
export nginx_config_dir="$(pwd)"

####################################################
# run prepare.sh
./prepare.sh
####################################################

####################################################
# Run the Ansible playbook with the desired parameters:
####################################################
ANSIBLE_HOST_KEY_CHECKING=False \
ansibleplaybook ${YAML} -i ${inventoryfile} -f 5  -u ${User}  \
--private-key=/keys/fedlab \
-e ansible_python_interpreter=/usr/bin/python3 \
--extra-vars "username=${User} inv=${inventory}  manager_ip=${manager_ip} \
dockeruser=${dockerUser} projectdiransible=${projectdiransible}" \
--ssh-common-args='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
