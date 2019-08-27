#!/usr/bin/env bash

echo get master info
SMS=/tmp/show_master_status.txt
mysql --login-path=root1 -ANe "SHOW MASTER STATUS" > ${SMS}
CURRENT_LOG=`cat ${SMS} | awk '{print $1}'`
CURRENT_POS=`cat ${SMS} | awk '{print $2}'`
echo CURRENT_LOG: ${CURRENT_LOG},  CURRENT_POS: ${CURRENT_POS}
echo replacing CURRENT_LOG and CURRENT_POS in the slave replication query
sed -i '' -e "s/MASTER_LOG_FILE='.*'/MASTER_LOG_FILE='${CURRENT_LOG}'/g" centos7/rep-mysql2.sql
sed -i '' -e "s/MASTER_LOG_POS=.*,/MASTER_LOG_POS=${CURRENT_POS},/g" centos7/rep-mysql2.sql


echo create replication user on master
cat $DIR/centos7/rep-mysql1.sql | mysql --login-path=root1

echo running replication query on slave
cat $DIR/centos7/rep-mysql2.sql | mysql --login-path=root2
