#!/usr/bin/env bash

echo loading data to mysql1
cat $DIR/centos7/mysql1-1.sql | mysql --login-path=root1

echo loading data to mysql2
cat $DIR/centos7/mysql2-1.sql | mysql --login-path=root2

