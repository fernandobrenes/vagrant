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

# SAVE ORACLE DATA IN DEVELOPMENT FOLDER
#sudo -s -u vagrant
ORACLEPATH=/development/oracle
if [[ ! -d "$ORACLEPATH" ]]; then
    sudo mkdir -p /development/oracle
fi
sudo chmod -R 2775 /development/oracle

MSGPATH=/development/oracle/msg_schema
if [[ ! -d "$MSGPATH" ]]; then
    sudo mkdir -p /development/oracle/msg_schema
fi
sudo chmod -R 2775 /development/oracle/msg_schema

MSMPATH=/development/oracle/msm_schema
if [[ ! -d "$MSMPATH" ]]; then
    sudo mkdir -p /development/oracle/msm_schema
fi
sudo chmod -R 2775 /development/oracle/msm_schema

MSG_SQL=/home/vagrant/02_msg.sql
if [[ ! -f "$MSG_SQL" ]]; then
    echo -e "${Red}02_msg.sql doesn't exist aborting${Color_Off}"
    exit 1
else
    sudo chmod 755 /home/vagrant/02_msg.sql
    sudo sed -i '1s/^/ALTER SESSION SET CONTAINER=FREEPDB1;\n/' /home/vagrant/02_msg.sql
fi

MSM_SQL=/home/vagrant/03_msm.sql
if [[ ! -f "$MSG_SQL" ]]; then
    echo -e "${Red}03_msm.sql doesn't exist aborting${Color_Off}"
    exit 1
else
    sudo chmod 755 /home/vagrant/03_msm.sql
    sudo sed -i '1s/^/ALTER SESSION SET CONTAINER=FREEPDB1;\n/' /home/vagrant/03_msm.sql
fi

 # INSTALL ORACLE   
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
    --volume /home/vagrant:/opt/oracle/scripts/startup \
    --publish 1521:1521 \
    container-registry.oracle.com/database/free:latest
fi
until [ "`docker inspect -f {{.State.Status}} oracle23`" == "running" ]; do sleep 1; done

if [ "`docker inspect -f {{.State.Status}} oracle23`" == "running" ]; then
    cat << EOF > /development/oracle/oracle-connect.txt
docker exec -it oracle23 sqlplus / as sysdba
docker exec -it oracle23 sqlplus sys/ct-ops@FREE as sysdba
docker exec -it oracle23 sqlplus system/ct-ops@FREE
docker exec -it oracle23 sqlplus pdbadmin/ct-ops@FREEPDB1
docker exec -it oracle23 sqlplus MSG_STG1/ct-ops@FREEPDB1
docker exec -it oracle23 sqlplus MSM_STG1/ct-ops@FREEPDB1

Connect from SQL Developer
Hostname: 10.10.0.80
Port: 1521
Service Name: FREEPDB1
Username: sys
Role: SYSDBA
Password: ct-ops

Connect from SQL Developer
Hostname: 10.10.0.80
Port: 1521
Service Name: FREEPDB1
Username: MSM_STG1
Role: default
Password: ct-ops

Connect from SQL Developer
Hostname: 10.10.0.80
Port: 1521
Service Name: FREEPDB1
Username: MSG_STG1
Role: default
Password: ct-ops
EOF
else 
    echo -e "Failed"
fi

# SCHEMA SPY
sudo wget https://download.oracle.com/otn-pub/otn_software/jdbc/233/ojdbc11.jar
curl -L https://github.com/schemaspy/schemaspy/releases/download/v6.2.4/schemaspy-6.2.4.jar \
    --output /home/vagrant/schemaspy.jar
sudo apt update
sudo apt install default-jre -y
sudo apt install graphviz -y

cat << EOF > /development/oracle/msg-schema.properties
# type of database. Run with -dbhelp for details
schemaspy.t=orathin-service
# path to the dowloaded oracle jdbc drivers, for example
schemaspy.dp=/home/vagrant/ojdbc11.jar
# database properties: host, port number, name user, password
schemaspy.host=10.10.0.80
schemaspy.port=1521
schemaspy.db=FREEPDB1
schemaspy.cat=%
schemaspy.u=MSG_STG1
schemaspy.p=ct-ops

# output dir to save generated files
schemaspy.o=$MSGPATH

# db scheme for which generate diagrams
schemaspy.s=MSG_STG1
EOF

cat << EOF > /development/oracle/msm-schema.properties
# type of database. Run with -dbhelp for details
schemaspy.t=orathin-service
# path to the dowloaded oracle jdbc drivers, for example
schemaspy.dp=/home/vagrant/ojdbc11.jar
# database properties: host, port number, name user, password
schemaspy.host=10.10.0.80
schemaspy.port=1521
schemaspy.db=FREEPDB1
schemaspy.cat=%
schemaspy.u=MSM_STG1
schemaspy.p=ct-ops

# output dir to save generated files
schemaspy.o=$MSMPATH

# db scheme for which generate diagrams
schemaspy.s=MSM_STG1
EOF

java -jar /home/vagrant/schemaspy.jar -configFile /development/oracle/msg-schema.properties
java -jar /home/vagrant/schemaspy.jar -configFile /development/oracle/msm-schema.properties

if [ $( docker container ls | grep msg | wc -l ) -gt 0 ]; then
        echo "msg container exists"
else
    docker run -it --rm -d -p 8081:80 --name msg -v /development/oracle/msg_schema:/usr/share/nginx/html nginx
fi

if [ $( docker container ls | grep msm | wc -l ) -gt 0 ]; then
        echo "msm container exists"
else
    docker run -it --rm -d -p 8082:80 --name msm -v /development/oracle/msm_schema:/usr/share/nginx/html nginx
fi


# CONNNECT
# docker exec -it oracle23 sqlplus / as sysdba
# docker exec -it oracle23 sqlplus sys/ct-ops@FREE as sysdba
# docker exec -it oracle23 sqlplus system/ct-ops@FREE
# docker exec -it oracle23 sqlplus pdbadmin/ct-ops@FREEPDB1

# Access Data:
#https://forums.docker.com/t/how-to-access-docker-volume-data-from-host-machine/88063
#https://earthly.dev/blog/docker-volumes/
#https://docs.oracle.com/en/learn/ol-db-free/index.html#connect-to-the-oracle-database-free-server-container