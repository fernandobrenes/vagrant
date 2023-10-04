#! /bin/bash
#title        :ansible.sh
#description  :This script install ansible in the system
#author       :Fernando Brenes
#date         :2023-09-27
#version      :1.0.0
#notes        :This script has no dependencies
set -euxo pipefail

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Cyan='\033[0;36m'         # Cyan
Color_Off='\033[0m'       # Text Reset

echo -e "${Cyan}***********************************************\n
Begin installing Ansible\n
***********************************************${Color_Off}"
if command -v ansible > /dev/null; then
    echo -e "${Green}Ansible is already installed, trying to update${Color_Off}"
    sudo apt-get update && sudo apt-get upgrade
else
    sudo apt update
    sudo apt install wget gpg -y
    UBUNTU_CODENAME=jammy
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
    sudo apt update && sudo apt install ansible -y

    # ADDING ANSIBLE INVENTORY
    cat << EOF >> /etc/ansible/hosts
webservers:
  hosts:
    slave-node01:
dbservers:
  hosts:
    slave-node02:
prod:
  hosts:
    slave-node01:
    slave-node02:
EOF
fi