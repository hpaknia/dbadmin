#!/usr/bin/env bash

echo get master info
SMS=/tmp/show_master_status.txt
mysql --login-path=root2 -ANe "SHOW MASTER STATUS" > ${SMS}
CURRENT_LOG=`cat ${SMS} | awk '{print $1}'`
CURRENT_POS=`cat ${SMS} | awk '{print $2}'`
echo CURRENT_LOG: ${CURRENT_LOG},  CURRENT_POS: ${CURRENT_POS}
echo replacing CURRENT_LOG and CURRENT_POS in the slave replication query

echo create replication user on slave
mysql --login-path=root2 << eof
-- GRANT USAGE ON *.* TO 'rep_user'@'%';
DROP USER IF EXISTS 'rep_user'@'%';
CREATE USER 'rep_user'@'%' IDENTIFIED BY 'rep_user';
GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';

DROP USER IF EXISTS 'nonroot'@'%';
CREATE USER 'nonroot'@'%' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON dba.* TO 'nonroot'@'%';

FLUSH PRIVILEGES;
eof

echo running replication query on slave
mysql --login-path=root1 << eof
CHANGE MASTER TO
    MASTER_HOST='mysql2',
    MASTER_USER='rep_user',
    MASTER_PASSWORD='rep_user',
 	MASTER_LOG_POS=${CURRENT_POS},
    MASTER_LOG_FILE='${CURRENT_LOG}',
    MASTER_PORT=3306;

RESET SLAVE;
START SLAVE;
eof
