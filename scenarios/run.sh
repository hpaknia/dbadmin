#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."

echo we do not have any passowrds set for any of the users
echo obviously we could use passwords, but then following lines would need user interactions

function setup_login_path() {
    if [ -z "$(mysql_config_editor print -G root$1)" ]; then
        mysql_config_editor set --login-path=root$1  --host=mysql$1 --port=3306 --user=root
    fi;
    if [ -z "$(mysql_config_editor print -G root$1)" ]; then
        mysql_config_editor set --login-path=nonroot$1  --host=mysql$1 --port=3306 --user=root
    fi;
}

setup_login_path 1
setup_login_path 2
setup_login_path 3

function check_connection() {
    dbc="0"
    # loop until mysql1 is connected
    while [ $dbc = "0" ]; do 
        mysql --login-path=root$1 -e "show databases" >/dev/null 2>&1 && dbc="1"
        if [ $dbc = "0" ]; then 
            echo "waiting for mysql$1..."
        else
            echo "mysql$1 connected"
        fi
        sleep 2;
    done
}

check_connection 1
check_connection 2
check_connection 3

source $DIR/scenarios/$1

