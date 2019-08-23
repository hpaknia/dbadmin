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

dbc="0"
# lopp until mysql1 is connected
while [ $dbc = "0" ]; do 
    mysql -h 127.0.0.1 -u root -P 33061 -e "show databases" >/dev/null 2>&1 && dbc="1"
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
    mysql -h 127.0.0.1 -u root -P 33062 -e "show databases" >/dev/null 2>&1 && dbc="1"
    if [ $dbc = "0" ]; then 
        echo "waiting for mysql2..."
    else
        echo "mysql2 connected"
    fi
    sleep 1;
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

# source $DIR/scenarios/01_utf8_to_latin1.sh
source $DIR/scenarios/05_latin1_tables.sh

# source $DIR/scenarios/05_latin1_tables.sh
source $DIR/scenarios/06_fill_latin1_data_mysql1.sh

source $DIR/scenarios/02_replicate_mysql1_to_mysql2.sh

source $DIR/scenarios/07_fill_in_employees_db.sh

# source $DIR/scenarios/03_fill_utf8_data_mysql1.sh

# source $DIR/scenarios/04_delete_mysql2_data.sh

source $DIR/scenarios/08_backup_only_schema.sh




read -p "Press enter to end"
teardown

# echo checking logs
# $dc logs -f
# docker-compose logs -f






