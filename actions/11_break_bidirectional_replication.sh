#!/usr/bin/env bash

read -p "Press enter to break replication"

query="SELECT SERVICE_STATE FROM performance_schema.replication_applier_status"
while [ true ]
do
	echo "INSERT INTO dba.x (id, name, original) VALUES (null, 'break', 'mysql1')" | mysql --login-path=root1 &
	echo "INSERT INTO dba.x (id, name, original) VALUES (null, 'break', 'mysql2')" | mysql --login-path=root2
	sleep 0.1
	if [ "$(echo $query | mysql --login-path=root1 -N)" = "OFF" ]; then 
		echo replication is broken!
		# insert more rows in the databse
		read -p "Press enter to continue inserting some rows"
		echo "REPLACE INTO dba.x (id, name, original) VALUES (100, 'break', 'mysql1')" | mysql --login-path=root1
		echo "REPLACE INTO dba.x (id, name, original) VALUES (101, 'break', 'mysql1')" | mysql --login-path=root1
		echo "REPLACE INTO dba.x (id, name, original) VALUES (102, 'break', 'mysql2')" | mysql --login-path=root2
		echo "REPLACE INTO dba.x (id, name, original) VALUES (103, 'break', 'mysql2')" | mysql --login-path=root2
		break
	fi
done

