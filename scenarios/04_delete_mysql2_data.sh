#!/usr/bin/env bash

echo try to wipe out x data on mysql2, but it will fail because of readonly issue
read -p "Press enter to continue"
cat $DIR/centos7/mysql2-2.sql | mysql --login-path=nonroot2
