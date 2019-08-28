#!/usr/bin/env bash

echo loading data to mysql1 latin1 

mysql --login-path=root1 << eof
DROP DATABASE IF EXISTS dba;
CREATE DATABASE dba CHARACTER SET latin1;
USE dba;
DROP TABLEs IF EXISTS x;
CREATE TABLE x (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(200) DEFAULT NULL,
  original varchar(200) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
eof