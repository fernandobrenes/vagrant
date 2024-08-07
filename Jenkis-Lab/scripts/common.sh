#! /bin/bash
#title        :common.sh
#description  :This script install commom utilities in the system based on the OS
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
Begin installing Utilities from common\n
***********************************************${Color_Off}"

# UPDATE AND UPGRADE
sudo apt-get update -y
sudo apt-get upgrade -y

# DNS SETTINGS
FILE=/etc/systemd/resolved.conf.d/dns_servers.conf
if [[ ! -f "$FILE" ]]; then
    sudo mkdir /etc/systemd/resolved.conf.d/
    cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
    [Resolve]
    DNS=${DNS_SERVERS}
EOF
else
    echo -e "${Green}dns_servers.conf already exist${Color_Off}"
fi

# INSTALL BASIC UTILITIES 
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == '"Ubuntu"' ]]; then
    echo -e "${Green}Ubuntu OS Detected, installing Basic Utilities${Color_Off}"
    sudo apt install linux-headers-$(uname -r) -y
    sudo add-apt-repository universe -y

elif [[ $OS == '"Debian GNU/Linux"' ]]; then
    echo -e "${Green}Debian OS Detected, installing KDE Plasma if not installed${Color_Off}"
    sudo apt install git git-man liberror-perl patch curl -y
    sudo apt install linux-headers-$(uname -r) -y
    PASSWD=vagrant
    echo "vagrant:$PASSWD" | chpasswd
    sudo sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
    sudo systemctl restart ssh.service
else
    echo -e "${Red}Uknown OS${Color_Off}"
    exit 1
fi

# COMMON BASIC UTILITIES
sudo timedatectl set-timezone America/Costa_Rica
sudo apt install jq -y
sudo apt install nfs-common -y
sudo apt install unzip -y
sudo apt install -y python3-pip
sudo apt install build-essential libssl-dev libffi-dev python3-dev python3-venv -y
sudo apt install vim -y