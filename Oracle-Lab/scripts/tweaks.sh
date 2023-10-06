
#! /bin/bash
#title        :development.sh
#description  :This script add some tweaks for Gnome
#author       :Fernando Brenes
#date         :2023-09-21
#version      :1.0.0
#notes        :This script has Gnome as dependency
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
Begin Tweaks for Gnome\n
***********************************************${Color_Off}"

OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == '"Ubuntu"' ]]; then
    echo -e "${Green}Ubuntu OS Detected${Color_Off}"
    export DISPLAY=:0.0
    sudo -u vagrant dbus-launch gsettings set org.gnome.desktop.session idle-delay 0
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

elif [[ $OS == '"Debian GNU/Linux"' ]]; then
    echo -e "${Green}Debian OS Detected${Color_Off}"
    export DISPLAY=:0.0
    sudo -u vagrant dbus-launch gnome-extensions enable dash-to-panel@jderose9.github.com
    sudo -u vagrant dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel panel-position LEFT
    sudo -u vagrant dbus-launch gsettings set org.gnome.desktop.session idle-delay 0
    sudo -u vagrant dbus-launch gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    sudo -u vagrant dbus-launch gsettings set org.gnome.desktop.background picture-uri file:///usr/share/desktop-base/homeworld-theme/wallpaper/gnome-background.xml
    #gnome-extensions enable dash-to-panel@jderose9.github.com
    #gsettings set org.gnome.shell.extensions.dash-to-panel panel-position LEFT
    #gsettings set org.gnome.desktop.session idle-delay 0
    #gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
else
    echo -e "${Red}Uknown OS${Color_Off}"
    exit 1
fi



