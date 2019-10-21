#!/usr/bin/env bash


echo create replication user on mysql$1

# query="
# -- START TRANSACTION;
# -- GRANT USAGE ON *.* TO 'rep_user'@'%';
# DROP USER IF EXISTS 'rep_user'@'%';
# CREATE USER 'rep_user'@'%' IDENTIFIED BY 'rep_user';
# GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';

# DROP USER IF EXISTS 'nonroot'@'%';
# CREATE USER 'nonroot'@'%' IDENTIFIED BY '';
# GRANT ALL PRIVILEGES ON dba.* TO 'nonroot'@'%';

# FLUSH PRIVILEGES;
# -- COMMIT;
# "
# echo "$query" | mysql --login-path=root$1

echo make mysql$1 readonly
query="SET @@GLOBAL.read_only = ON" 
echo $query | mysql --login-path=root$1

echo backup with gtid from mysql$1 to mysql$2
mysqldump --login-path=root$1 --set-gtid-purged=OFF --all-databases --triggers --routines --events | mysql --login-path=root$2

echo set master of mysql$2 to mysql$1
mysql --login-path=root$2 << eof
CHANGE MASTER TO
    MASTER_HOST='mysql$1',
    MASTER_USER='rep_user',
    MASTER_PASSWORD='rep_user',
    MASTER_PORT=3306,
    MASTER_AUTO_POSITION = 1;
START SLAVE;
eof

echo make mysql$1 writable
query="SET @@GLOBAL.read_only = OFF" 
echo $query | mysql --login-path=root$1
