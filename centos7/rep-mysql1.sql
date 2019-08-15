GRANT USAGE ON *.* TO 'rep_user'@'%';
DROP USER 'rep_user'@'%';
CREATE USER 'rep_user'@'%' IDENTIFIED BY 'rep_user';
GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';
FLUSH PRIVILEGES;
