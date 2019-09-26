#!/usr/bin/env bash

set -e

DIR=`realpath $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/..`

echo we do not have any passowrds set for any of the users
echo obviously we could use passwords, but then following lines would need user interactions
if [ -z "$(mysql_config_editor print -G root1)" ]; then
    mysql_config_editor set --login-path=root1  --host=mysql1 --port=3306 --user=root
fi;

if [ -z "$(mysql_config_editor print -G root2)" ]; then
    mysql_config_editor set --login-path=root2  --host=mysql2 --port=3306 --user=root
fi;

if [ -z "$(mysql_config_editor print -G nonroot1)" ]; then
    mysql_config_editor set --login-path=nonroot1  --host=mysql1 --port=3306 --user=nonroot
fi;

if [ -z "$(mysql_config_editor print -G nonroot2)" ]; then
    mysql_config_editor set --login-path=nonroot2  --host=mysql2 --port=3306 --user=nonroot
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

source $DIR/scenarios/$1

