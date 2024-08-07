#! /bin/bash
#title        :ui.sh
#description  :This script Check VB version so we can assure it's the latest version and have latest version of Virtual Guest Addons
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
Begin Checking Virtual Box Version\n
***********************************************${Color_Off}"

# INSTALL UI BASED ON OS 
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == '"Ubuntu"' ]]; then
    echo -e "${Green}Ubuntu OS Detected, installing Desktop minimal if not installed${Color_Off}"
    VMBOX_LATEST=$(curl -s http://download.virtualbox.org/virtualbox/LATEST.TXT)
    echo "$VIRTUALBOX_VERSION"
    echo "$VMBOX_LATEST"
    if [[ "$VMBOX_LATEST" != "$VIRTUALBOX_VERSION" ]]; then
       echo -e "${Red}Please install latest VirtualBox version to proceed!${Color_Off}"
       exit 1
    else 
        FILE=/opt/VBoxGuestAdditions-$VMBOX_LATEST/bin/VBoxClient
        ISOPATH=/media/iso
        if [[ ! -f "$FILE" ]]; then
            echo -e "${Red}Not running latest VirtualGuest version!${Color_Off}"
            wget http://download.virtualbox.org/virtualbox/$VMBOX_LATEST/VBoxGuestAdditions_$VMBOX_LATEST.iso
            
            if [[ ! -d "$ISOPATH" ]]; then
                sudo mkdir /media/iso
            fi

            sudo umount /media/iso
            sudo mount VBoxGuestAdditions_$VMBOX_LATEST.iso /media/iso
            sudo /media/iso/VBoxLinuxAdditions.run || true
            sudo umount /media/iso
            sudo rm -rf VBoxGuestAdditions_$VMBOX_LATEST.iso

        else
            echo -e "${Cyan}Running latest VirtualGuest version!${Color_Off}"
        fi
    fi

elif [[ $OS == '"Debian GNU/Linux"' ]]; then
    echo -e "${Green}Debian OS Detected${Color_Off}"
    sudo apt-get update -y
    sudo apt install curl -y
    VMBOX_LATEST=$(curl -s http://download.virtualbox.org/virtualbox/LATEST.TXT)
    echo "$VIRTUALBOX_VERSION"
    echo "$VMBOX_LATEST"
    if [[ "$VMBOX_LATEST" != "$VIRTUALBOX_VERSION" ]]; then
       echo -e "${Red}Please install latest VirtualBox version to proceed!${Color_Off}"
       exit 1
    else 
        FILE=/opt/VBoxGuestAdditions-$VMBOX_LATEST/bin/VBoxClient
        ISOPATH=/media/iso
        
        if [[ ! -f "$FILE" ]]; then
            echo -e "${Red}Not running latest VirtualGuest version!${Color_Off}"
            wget http://download.virtualbox.org/virtualbox/$VMBOX_LATEST/VBoxGuestAdditions_$VMBOX_LATEST.iso
            
            if [[ ! -d "$ISOPATH" ]]; then
                sudo mkdir $ISOPATH
            fi
            if mountpoint -q $ISOPATH; then
                sudo umount $ISOPATH
            fi
            sudo mount VBoxGuestAdditions_$VMBOX_LATEST.iso $ISOPATH
            sudo $ISOPATH/VBoxLinuxAdditions.run || true
            sudo umount $ISOPATH
            sudo rm -rf VBoxGuestAdditions_$VMBOX_LATEST.iso

        else
            echo -e "${Cyan}Running latest VirtualGuest version!${Color_Off}"       
        fi  
    fi
else
    echo -e "${Red}Uknown OS${Color_Off}"
    exit 1
fi