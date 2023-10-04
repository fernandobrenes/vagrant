#! /bin/bash
#title        :ansible-conf.sh
#description  :This script configure ansible in the system
#author       :Fernando Brenes
#date         :2023-09-27
#version      :1.0.0
#notes        :This script has ansible as dependency
#set -euxo pipefail

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Cyan='\033[0;36m'         # Cyan
Color_Off='\033[0m'       # Text Reset

echo -e "${Cyan}***********************************************\n
Configuring Ansible\n
***********************************************${Color_Off}"

FILE=~/.ssh/known_hosts
if [[ ! -f "$FILE" ]]; then
    touch ~/.ssh/known_hosts
    yes '' | ssh-keygen -N '' > /dev/null
    slaves=("slave-node01" "slave-node02")
    for h in ${slaves[@]}; do
        if [ -z "$(ssh-keygen -F $h)" ]; then
        ssh-keyscan -H $h >> ~/.ssh/known_hosts
        sshpass -p vagrant ssh-copy-id vagrant@$h
        fi
    done
    ansible all -m ping -u vagrant
else
    echo -e "${Green}~/.ssh/known_hosts already exist${Color_Off}"
fi

#for ip in 10.10.0.{51..52}; do
#    if [ -z "$(ssh-keygen -F $ip)" ]; then
#        ssh-keyscan -H $ip >> ~/.ssh/known_hosts
#	fi
#done

