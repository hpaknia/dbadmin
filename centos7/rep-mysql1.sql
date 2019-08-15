-- GRANT USAGE ON *.* TO 'rep_user'@'%';
DROP USER IF EXISTS 'rep_user'@'%';
CREATE USER 'rep_user'@'%' IDENTIFIED BY 'rep_user';
GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';

DROP USER IF EXISTS 'nonroot'@'%';
CREATE USER 'nonroot'@'%' IDENTIFIED BY 'nonroot';
GRANT ALL PRIVILEGES ON dba.* TO 'nonroot'@'%';

FLUSH PRIVILEGES;

