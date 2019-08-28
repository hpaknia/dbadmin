#!/usr/bin/env bash

echo try to wipe out x data on mysql2, but it will fail because of readonly issue
read -p "Press enter to continue"
cat $DIR/centos7/mysql2-2.sql | mysql --login-path=nonroot2 << eof
use dba;

truncate table x; 
-- ERROR 1290 (HY000) at line 2: The MySQL server is running with the --read-only option so it cannot execute this statement
eof


