#! /bin/bash
#title        :ui.sh
#description  :This script install the UI in the system based on the OS
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
Begin installing UI\n
***********************************************${Color_Off}"

# UPDATE AND UPGRADE
sudo apt-get update -y
sudo apt-get upgrade -y

# INSTALL UI BASED ON OS 
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == '"Ubuntu"' ]]; then
    echo -e "${Green}Ubuntu OS Detected, installing Desktop minimal if not installed${Color_Off}"
    sudo apt install ubuntu-desktop-minimal -y
    sudo apt install dbus-x11 -y
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

elif [[ $OS == '"Debian GNU/Linux"' ]]; then
    echo -e "${Green}Debian OS Detected, installing KDE Plasma if not installed${Color_Off}"
    sudo apt install gnome-core -y
    sudo apt-get install -y gnome-shell-extension-dash-to-panel
    sudo apt install gnome-tweaks -y
    sudo apt install dbus-x11 -y
    #sudo apt install gnome/stable -y
    #sudo apt install cinnamon-core -y
    #sudo apt install kde-plasma-desktop
else
    echo -e "${Red}Uknown OS${Color_Off}"
    exit 1
fi