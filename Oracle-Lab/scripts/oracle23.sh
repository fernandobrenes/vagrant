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
Begin installing Oracle\n
***********************************************${Color_Off}"

# SAVE JENKINS CREDENTIALS IN DEVELOPMENT FOLDER
#sudo -s -u vagrant
sudo mkdir -p /development/oracle
sudo chmod -R 2775 /development/oracle

 # INSTALL JENKINS   
if [ ! "$(docker network ls | grep oracle)" ]; then
    echo "Creating Oracle network ..."
    docker network create oracle
else
    echo -e "${Green}oracle network already exist${Color_Off}"
fi

if [ $( docker container ls | grep oracle23 | wc -l ) -gt 0 ]; then
        echo "oracle23 exists"
    else
        docker run \
        --name oracle23 \
        --restart=on-failure \
        --detach \
        --network oracle \
        --env ORACLE_PWD=ct-ops \
        --volume  oracle-data:/opt/oracle/oradata \
        --publish 1521:1521 \
        container-registry.oracle.com/database/free:latest
fi
until [ "`docker inspect -f {{.State.Status}} oracle23`" == "running" ]; do sleep 1; done

if [ "`docker inspect -f {{.State.Status}} oracle23`" == "running" ]; then
    cat << EOF > /development/oracle/oracle-connect.txt
docker exec -it oracle21 sqlplus / as sysdba
docker exec -it oracle21 sqlplus sys/ct-ops@FREE as sysdba
docker exec -it oracle21 sqlplus system/ct-ops@FREE
docker exec -it oracle21 sqlplus pdbadmin/ct-ops@FREEPDB1

Connect from SQL Developer
Hostname: 10.10.0.70
Port: 1521
Service Name: FREEPDB1
Username: sys
Role: SYSDBA
Password: ct-ops
EOF
else 
    echo -e "Failed"
fi


# CONNNECT
# docker exec -it oracle21 sqlplus / as sysdba
# docker exec -it oracle21 sqlplus sys/ct-ops@FREE as sysdba
# docker exec -it oracle21 sqlplus system/ct-ops@FREE
# docker exec -it oracle21 sqlplus pdbadmin/ct-ops@FREEPDB1