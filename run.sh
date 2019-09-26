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

echo run the scenario in the centos box 

# docker exec centos7 bash -c "export DIR=/mounted && /mounted/scenarios/01_backup.sh"
# docker exec centos7 bash -c "export DIR=/mounted && /mounted/scenarios/02_bidirectional_replication.sh"
docker exec centos7 bash -c "/mounted/scenarios/run.sh 03_bidirectional_replication_gtid.sh"

read -p "Press enter to end"
teardown

# echo checking logs
# $dc logs -f
# docker-compose logs -f






