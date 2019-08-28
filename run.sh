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

echo clean up mysql data
rm -rf $DIR/data/*

echo create backups directory
mkdir -p "${DIR}/backups"

echo clean up backups
rm -rf $DIR/backups/*

echo starting the containers
$dc up --force-recreate --build --remove-orphans -d

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

dbc="0"
# loop until mysql1 is connected
while [ $dbc = "0" ]; do 
    mysql --login-path=root1 -e "show databases" >/dev/null 2>&1 && dbc="1"
    if [ $dbc = "0" ]; then 
        echo "waiting for mysql1..."
    else
        echo "mysql1 connected"
    fi
    sleep 2;
done

dbc="0"
# lopp until mysql2 is connected
while [ $dbc = "0" ]; do 
    mysql --login-path=root2 -e "show databases" >/dev/null 2>&1 && dbc="1"
    if [ $dbc = "0" ]; then 
        echo "waiting for mysql2..."
    else
        echo "mysql2 connected"
    fi
    sleep 1;
done


source $DIR/scenarios/01_backup.sh

read -p "Press enter to end"
teardown

# echo checking logs
# $dc logs -f
# docker-compose logs -f






