#!/usr/bin/env bash

# trying to get the last execution id
server_uuid_1=`echo "SHOW GLOBAL VARIABLES LIKE 'server_uuid'" | mysql --login-path=root1 -N | awk '{print $2}'`
gtid_executed_1=`echo "SHOW GLOBAL VARIABLES LIKE 'gtid_executed'" | mysql --login-path=root1 -N | awk '{print $2}' | tr ',' '\n' | grep -v $server_uuid_1`
server_uuid_2=`echo "SHOW GLOBAL VARIABLES LIKE 'server_uuid'" | mysql --login-path=root2 -N | awk '{print $2}'`
gtid_executed_2=`echo "SHOW GLOBAL VARIABLES LIKE 'gtid_executed'" | mysql --login-path=root2 -N | awk '{print $2}' | tr ',' '\n' | grep -v $server_uuid_2`

# a string containing all of the recent execution ids
gtid_executed=`echo "${gtid_executed_1},${gtid_executed_2}" | tr ',' '\n' | sed 's/\\\n//g'`
# get the actual number and inc
gtid_executed_number_1=`echo "$gtid_executed" | grep $server_uuid_1 | sed -e 's/.*[:-]//g'`
((gtid_executed_number_1++))
gtid_executed_number_2=`echo "$gtid_executed" | grep $server_uuid_2 | sed -e 's/.*[:-]//g'`
((gtid_executed_number_2++))

echo These are suggested queries to run to fix the replication:
fix_1="SET @@SESSION.GTID_NEXT='${server_uuid_2}:${gtid_executed_number_2}';
BEGIN;
COMMIT;
SET GTID_NEXT='AUTOMATIC';
START SLAVE;"
echo Fix server 1
echo "${fix_1}"
fix_2="SET @@SESSION.GTID_NEXT='${server_uuid_1}:${gtid_executed_number_1}';
BEGIN;
COMMIT;
SET GTID_NEXT='AUTOMATIC';
START SLAVE;"
echo Fix server 2
echo "${fix_2}"


ans=""
echo "Pres y to run the queries against pertinent severs, press any other key to skip"
read -n1 ans
echo 

if [ "$ans" = "y" ]; then
	echo fixing mysql 1
	echo $fix_1 | mysql --login-path=root1
	echo fixing mysql 2
	echo $fix_2 | mysql --login-path=root2
fi

echo Check the results...