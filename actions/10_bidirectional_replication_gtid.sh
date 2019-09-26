#!/usr/bin/env bash


echo create replication user on master and slave

query="
-- GRANT USAGE ON *.* TO 'rep_user'@'%';
DROP USER IF EXISTS 'rep_user'@'%';
CREATE USER 'rep_user'@'%' IDENTIFIED BY 'rep_user';
GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';

DROP USER IF EXISTS 'nonroot'@'%';
CREATE USER 'nonroot'@'%' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON dba.* TO 'nonroot'@'%';

FLUSH PRIVILEGES;
"
echo "$query" | mysql --login-path=root1
echo "$query" | mysql --login-path=root2

echo make mysql1 and mysql2 readonly
query="SET @@GLOBAL.read_only = ON" 
echo $query | mysql --login-path=root1
echo $query | mysql --login-path=root2

echo backup with gtid from mysql1 to mysql2
mysqldump --login-path=root1 --column-statistics=0 --set-gtid-purged=OFF --all-databases --triggers --routines --events | mysql --login-path=root2

echo set master of each server to the other
mysql --login-path=root1 << eof
CHANGE MASTER TO
    MASTER_HOST='mysql2',
    MASTER_USER='rep_user',
    MASTER_PASSWORD='rep_user',
    MASTER_PORT=3306,
    MASTER_AUTO_POSITION = 1;
START SLAVE;
eof
mysql --login-path=root2 << eof
CHANGE MASTER TO
    MASTER_HOST='mysql1',
    MASTER_USER='rep_user',
    MASTER_PASSWORD='rep_user',
    MASTER_PORT=3306,
    MASTER_AUTO_POSITION = 1;
START SLAVE;
eof

echo make mysql1 and mysql2 writable
query="SET @@GLOBAL.read_only = OFF" 
echo $query | mysql --login-path=root1
echo $query | mysql --login-path=root2
