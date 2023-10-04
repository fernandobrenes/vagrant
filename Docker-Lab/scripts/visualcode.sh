#! /bin/bash
#title        :visualcode.sh
#description  :This script install visual code if it doesn't exist
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
Begin Installing Visual Code from visualcode\n
***********************************************${Color_Off}"

# INSTALL VISUAL CODE
if command -v code > /dev/null; then
    echo -e "${Green}Visual Code is already installed, trying to update${Color_Off}"
    sudo apt-get update && sudo apt-get upgrade
else
    echo -e "${Cyan}***********************************************\n
    Installing Visual Code\n
    ***********************************************${Color_Off}"
    sudo apt-get install wget gpg -y
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https -y
    sudo apt update -y
    sudo apt install code -y
fi