#! /bin/bash
#title        :kubernetes.sh
#description  :This script install Kubernetes if it doesn't exist
#author       :Fernando Brenes
#date         :2023-09-11
#version      :1.0.0
#notes        :This script has docker as a dependency
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
Begin OpenLens\n
***********************************************${Color_Off}"
FILE=/opt/openlens/linux-unpacked/open-lens
if [ -f "$FILE" ]; then
    echo "Open Lens is already installed."
else 
    sudo apt-get install -y make g++
    sudo apt install libfuse2 -y
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    source ~/.nvm/nvm.sh
    echo "source ~/.nvm/nvm.sh" >> ~/.bashrc
    OPENLENS_VERSION=$(curl -s https://api.github.com/repos/lensapp/lens/releases/latest | sed -En 's/  "tag_name": "(.+)",/\1/p')
    curl -L https://github.com/lensapp/lens/archive/refs/tags/$OPENLENS_VERSION.tar.gz | tar xvz
    mv lens-* lens 
    cd lens
    nvm install 16 && nvm use 16 #&& npm install -g yarn
    npm install -g npm@^9.6.7
    #npm i lerna
    npm install
    npm run build
    npm run build:app -- --scope=open-lens -- --dir
    #npm run build:app

    sudo mkdir /opt/openlens/
    sudo mv open-lens/dist/linux-unpacked /opt/openlens/
    sudo cp packages/core/build/icon.png /opt/openlens/
    sudo chown -R vagrant:vagrant /opt/openlens/
    #chmod +x /opt/openlens/openlens.AppImage
    #cp packages/core/build/icon.png /opt/openlens/
    sudo rm -rf /home/vagrant/lens

    # CREATE A LAUNCHER
    sudo mkdir /home/vagrant/.local/share/applications
    sudo chown -R vagrant:vagrant /home/vagrant/.local/share/applications
cat << EOF > /home/vagrant/.local/share/applications/OpenLens.desktop
[Desktop Entry]
Comment[en_GB]=
Comment=Kubernetes Client
Exec=/opt/openlens/linux-unpacked/open-lens
GenericName[en_GB]=
GenericName=
Icon=/opt/openlens/icon.png
Name[en_GB]=OpenLens
Name=OpenLens
NoDisplay=false
Path=/opt/openlens/
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-KDE-SubstituteUID=false
X-KDE-Username=
MimeType=x-scheme-handler/lens;text/html;
EOF
fi
