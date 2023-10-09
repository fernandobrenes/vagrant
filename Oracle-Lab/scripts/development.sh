#! /bin/bash
#title        :development.sh
#description  :This script partition a new disk and add share it with vagrant using a group named development
#author       :Fernando Brenes
#date         :2023-09-11
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
Begin Partitioning Disk from development\n
***********************************************${Color_Off}"

if ! grep -qF "/development" /etc/fstab; then
    echo -e "${Cyan}***********************************************\n
    Partitioning Disk and mount it on /development\n
    ***********************************************${Color_Off}"
    # INSTALL DOCKER BASED ON OS 
    OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    if [[ $OS == '"Ubuntu"' ]]; then
        echo -e "${Green}Ubuntu OS Detected${Color_Off}"
        sudo wipefs -a -f /dev/sdb
        sudo parted /dev/sdb mklabel gpt --script
        sudo parted -a opt /dev/sdb mkpart primary ext4 1MiB 100% --script
        sudo mkfs.ext4 -L development /dev/sdb1
        sudo mkdir -p /development
        echo "LABEL=development /development ext4 defaults 0 1" | sudo tee -a /etc/fstab
        sudo mount -av
        sudo chgrp -R vagrant /development
        sudo chmod -R 2775 /development
    elif [[ $OS == '"Debian GNU/Linux"' ]]; then
        echo -e "${Green}Debian OS Detected${Color_Off}"
        sudo apt-get update
        sudo apt-get -y install parted
        sudo wipefs -a -f /dev/sdb
        sudo parted /dev/sdb mklabel gpt --script
        sudo parted -a opt /dev/sdb mkpart primary ext4 1MiB 100% --script
        sudo mkfs.ext4 -L development /dev/sdb1
        sudo mkdir -p /development
        echo "LABEL=development /development ext4 defaults 0 1" | sudo tee -a /etc/fstab
        sudo mount -av
        sudo chgrp -R vagrant /development
        sudo chmod -R 2775 /development
        sudo growpart /dev/sda 1
        sudo /sbin/resize2fs /dev/sda1
    else
        echo -e "${Red}Uknown OS${Color_Off}"
        exit 1
    fi  
else
    echo -e "${Green}/development mountpoint already in /etc/fstab${Color_Off}"
fi

