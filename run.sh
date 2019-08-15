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
$dc up --force-recreate -d

export MYSQL_PWD=root

nc1="0"
nc2="0"
while [ $nc1 = "0" ] || [ $nc2 = "0" ]; do 
    sleep 1;
    if [ $nc1 = "0" ]; then
        nc1="1"
        mysql -h 127.0.0.1 -u root -P 33061 -e "show databases" >/dev/null 2>&1 || nc1="0"
        if [ $nc1 = "0" ]; then 
            echo "waiting for mariadb..."
        else
            echo "mariadb connected"
        fi
    fi

    sleep 1;
    if [ $nc2 = "0" ]; then
        nc2="1"
        mysql -h 127.0.0.1 -u root -P 33062 -e "show databases" >/dev/null 2>&1 > /dev/null || nc2="0"
        if [ $nc2 = "0" ]; then 
            echo "waiting for mysql..."
        else
            echo "mysqldb connected"
        fi
    fi
done


mysql_config_editor set --login-path=mysql1  --host=127.0.0.1 --port=33061 --user=root --password=root
mysql_config_editor set --login-path=mysql2  --host=127.0.0.1 --port=33061 --user=root --password=root

echo loading dat to mariadb
cat $DIR/centos7/mysql1.sql | mysql --login-path=mysql1

echo loading data to mysqldb
cat $DIR/centos7/mysql2.sql | mysql --login-path=mysql2

echo get master info
SMS=/tmp/show_master_status.txt
mysql --login-path=mysql1 -ANe "SHOW MASTER STATUS" > ${SMS}
CURRENT_LOG=`cat ${SMS} | awk '{print $1}'`
CURRENT_POS=`cat ${SMS} | awk '{print $2}'`
echo CURRENT_LOG: ${CURRENT_LOG},  CURRENT_POS: ${CURRENT_POS}
echo replacing CURRENT_LOG and CURRENT_POS in the slave replication query
sed -i '' -e "s/MASTER_LOG_FILE='.*',/MASTER_LOG_FILE='${CURRENT_LOG}',/g" centos7/rep-mysql2.sql
sed -i '' -e "s/MASTER_LOG_POS='.*',/MASTER_LOG_POS=${CURRENT_POS},/g" centos7/rep-mysql2.sql

echo running replication queries
cat $DIR/centos7/rep-mysql1.sql | mysql --login-path=mysql1
cat $DIR/centos7/rep-mysql2.sql | mysql --login-path=mysql2


