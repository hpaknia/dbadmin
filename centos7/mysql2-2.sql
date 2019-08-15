use dba;

truncate table x; 
-- ERROR 1290 (HY000) at line 2: The MySQL server is running with the --read-only option so it cannot execute this statement
