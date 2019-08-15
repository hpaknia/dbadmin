#!/usr/bin/env bash

docker -v

echo get the default directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

dc="docker-compose -f ${DIR}/docker-compose.yml"

function teardown() {
    $dc stop  || true
    $dc rm -f || true
}

echo trap teardown function for INT and ERR
trap "teardown;exit 1;" INT ERR

echo stop the containers if running
teardown

echo starting the containers
$dc up --force-recreate --build --remove-orphans -d

export MYSQL_PWD=root

nc1="0"
nc2="0"
while [ $nc1 = "0" ] || [ $nc2 = "0" ]; do 
    sleep 3;
    if [ $nc1 = "0" ]; then
        nc1="1"
        mysql -h 127.0.0.1 -u root -P 33061 -e "show databases" >/dev/null 2>&1 || nc1="0"
        if [ $nc1 = "0" ]; then 
            echo "waiting for mysql1..."
        else
            echo "mysql1 connected"
        fi
    fi

    if [ $nc2 = "0" ]; then
        nc2="1"
        mysql -h 127.0.0.1 -u root -P 33062 -e "show databases" >/dev/null 2>&1 > /dev/null || nc2="0"
        if [ $nc2 = "0" ]; then 
            echo "waiting for mysql2..."
        else
            echo "mysql2 connected"
        fi
    fi
done

echo if asked for passwords, they are same as usernames, either root or nonroot
if [ -z "$(mysql_config_editor print -G root1)" ]; then
    echo enter root password for mysql1
    mysql_config_editor set --login-path=root1  --host=127.0.0.1 --port=33061 --user=root --password
fi;

if [ -z "$(mysql_config_editor print -G root2)" ]; then
    echo enter root password for mysql2
    mysql_config_editor set --login-path=root2  --host=127.0.0.1 --port=33062 --user=root --password
fi;

if [ -z "$(mysql_config_editor print -G nonroot1)" ]; then
    echo enter nonroot password for mysql1
    mysql_config_editor set --login-path=nonroot1  --host=127.0.0.1 --port=33061 --user=nonroot --password
fi;

if [ -z "$(mysql_config_editor print -G nonroot2)" ]; then
    echo enter nonroot password for mysql2
    mysql_config_editor set --login-path=nonroot2  --host=127.0.0.1 --port=33062 --user=nonroot --password
fi;

echo loading data to mysql1
cat $DIR/centos7/mysql1-1.sql | mysql --login-path=root1

echo loading data to mysql2
cat $DIR/centos7/mysql2-1.sql | mysql --login-path=root2

echo get master info
SMS=/tmp/show_master_status.txt
mysql --login-path=root1 -ANe "SHOW MASTER STATUS" > ${SMS}
CURRENT_LOG=`cat ${SMS} | awk '{print $1}'`
CURRENT_POS=`cat ${SMS} | awk '{print $2}'`
echo CURRENT_LOG: ${CURRENT_LOG},  CURRENT_POS: ${CURRENT_POS}
echo replacing CURRENT_LOG and CURRENT_POS in the slave replication query
sed -i '' -e "s/MASTER_LOG_FILE='.*'/MASTER_LOG_FILE='${CURRENT_LOG}'/g" centos7/rep-mysql2.sql
sed -i '' -e "s/MASTER_LOG_POS=.*,/MASTER_LOG_POS=${CURRENT_POS},/g" centos7/rep-mysql2.sql


echo create replication user on master
cat $DIR/centos7/rep-mysql1.sql | mysql --login-path=root1

echo running replication query on slave
cat $DIR/centos7/rep-mysql2.sql | mysql --login-path=root2

echo testing replication
echo create table x with data must appear in mysql2
read -p "Press enter to continue"
# cat $DIR/centos7/mysql1-2.sql | mysql --login-path=root1 --default-character-set=utf8  
mysql --login-path=root1 dba << eof
use dba;
SET NAMES 'utf8';
SET CHARACTER SET utf8;
create table if not exists x (
    id int auto_increment Primary Key, 
    name varchar(200) default null, 
    original varchar(200) default null
) DEFAULT CHARSET=utf8;
INSERT INTO x (id, name, original)
VALUES
    (1, 'dba', 'dba'),
    (2, 'hassan', 'حسن'),
    (null, 'Clement', 'मेहरबान'),
    (20, 'dba', 'dba');

eof

echo try to wipe out x data on mysql2, but it will fail because of readonly issue
read -p "Press enter to continue"
cat $DIR/centos7/mysql2-2.sql | mysql --login-path=nonroot2

read -p "Press enter to end"


# echo checking logs
# $dc logs -f






