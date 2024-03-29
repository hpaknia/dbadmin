#!/usr/bin/env bash

date=$(date '+%Y-%m-%d_%H-%M-%S')
schema_backup="${date}.schema.sql"
view_procedure_backup="${date}.view.procedures.sql"
all_without_gtid_backup="${date}.all.without.gtid.sql"
all_with_gtid_backup="${date}.all.with.gtid.sql"
all_without_gtid_but_server_has_gtid_backup="${date}.all.without.gtid.but.server.has.gtid.sql"

echo backup only schema, excluding views

ignore=$(mysql --login-path=root1 INFORMATION_SCHEMA \
	--skip-column-names --batch \
	-e "select group_concat(concat('--ignore-table=', table_schema, '.', table_name) SEPARATOR ' ') 
	from tables 
	where table_type = 'VIEW' and table_schema = 'employees'")

mysqldump --login-path=root1  --no-data employees $ignore > "$DIR/backups/$schema_backup"	

echo backup only and only views and procedures

mysql --login-path=root1 INFORMATION_SCHEMA \
	--skip-column-names --batch \
	-e "select table_name from tables where table_type = 'VIEW' and table_schema = 'employees'" \
	| xargs mysqldump --login-path=root1  --no-data -R employees > "$DIR/backups/$view_procedure_backup"


echo backup all without gtid
mysqldump --login-path=root1  --set-gtid-purged=OFF --all-databases --triggers --routines --events  > "$DIR/backups/$all_without_gtid_backup"

echo enabling gtid on the server, wait got gtid is enabled message

set -e

command='SHOW VARIABLES LIKE "%gtid%"'
echo $command
mysql --login-path=root1 -e "$query"
mysql --login-path=root2 -e "$query"

command='SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = WARN'
echo $command
mysql --login-path=root1 -e "$query"
sleep 0.5
mysql --login-path=root2 -e "$query"
sleep 0.5

command='SET @@GLOBAL.GTID_MODE = OFF_PERMISSIVE'
echo $command
mysql --login-path=root1 -e "$query"
sleep 0.5
mysql --login-path=root2 -e "$query"
sleep 0.5

command='SET @@GLOBAL.GTID_MODE = ON_PERMISSIVE'
echo $command
mysql --login-path=root1 -e "$query"
sleep 0.5
mysql --login-path=root2 -e "$query"
sleep 1.5

# while [ ! "$(mysql --login-path=root1 -e 'SHOW STATUS LIKE "ONGOING_ANONYMOUS_TRANSACTION_COUNT"')" == "0" ]; do echo 'sleep 1'; sleep 1; done;
# while [ ! "$(mysql --login-path=root2 -e 'SHOW STATUS LIKE "ONGOING_ANONYMOUS_TRANSACTION_COUNT"')" == "0" ]; do echo 'sleep 1'; sleep 1; done;

echo wait 3 seconds for ONGOING_ANONYMOUS_TRANSACTION_COUNT to become zero
sleep 2

echo slave gtid info after
command='SET @@GLOBAL.GTID_MODE = ON'
echo $command
mysql --login-path=root1 -e "$query"
sleep 0.1
mysql --login-path=root2 -e "$query"

echo gtid is enabled message

echo backup all with gtid
mysqldump --login-path=root1  --set-gtid-purged=ON --all-databases --triggers --routines --events  > "$DIR/backups/$all_with_gtid_backup"

echo backup all without gtid, but server gtid is enabled
mysqldump --login-path=root1  --set-gtid-purged=OFF --all-databases --triggers --routines --events  > "$DIR/backups/$all_without_gtid_but_server_has_gtid_backup"

# ls -ltrh $DIR/backups/ | head -n 5


