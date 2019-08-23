#!/usr/bin/env bash

echo testing replication
echo create table x on mysql1 with data must appear in mysql2
read -p "Press enter to continue"
# cat $DIR/centos7/mysql1-2.sql | mysql --login-path=root1 --default-character-set=utf8  
cat $DIR/centos7/mysql1-2.sql | mysql --login-path=root1
