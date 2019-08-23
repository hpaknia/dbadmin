#!/usr/bin/env bash

echo creating employees db with procedures

mysql --login-path=root1 << eof

DROP DATABASE IF EXISTS employees;
CREATE DATABASE IF NOT EXISTS employees;
USE employees;

SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';

DROP TABLE IF EXISTS employees, departments;

/*!50503 set default_storage_engine = InnoDB */;
/*!50503 select CONCAT('storage engine: ', @@default_storage_engine) as INFO */;

CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,
    dept_name   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (dept_no),
    UNIQUE  KEY (dept_name)
);
insert into departments VALUES (4321, 'whatever1'), (5432, 'whatever2');

CREATE TABLE employees (
    emp_no      INT             NOT NULL,
    dept_no     CHAR(4)         NOT NULL,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      ENUM ('M','F')  NOT NULL,    
    hire_date   DATE            NOT NULL,
    PRIMARY KEY (emp_no)
);
insert into employees VALUES (1111, 5432, '1990-01-22', 'h', 'P.M.', 'M', '2018-11-16');

eof


echo adding procedures

mysql --login-path=root1 << eof
USE employees;

DELIMITER \$\$

CREATE PROCEDURE addDepartment
(
  IN p_dept_no CHAR(4), 
  IN p_dept_name VARCHAR(40)
)
BEGIN
  DECLARE v_lastInsertId MEDIUMINT;
  INSERT INTO departments SET dept_no = p_dept_no, dept_name = p_dept_name;
  SET v_lastInsertId = LAST_INSERT_ID();
  SELECT v_lastInsertId;
END \$\$

DELIMITER ;

CALL addDepartment (1234, 'for Clement');
eof

echo create view
mysql --login-path=root1 << eof
USE employees;
CREATE VIEW emp AS SELECT e.*, d.dept_name from employees e join departments d on e.dept_no = d.dept_no;
CREATE VIEW emp2 AS SELECT e.emp_no as number, d.dept_name from employees e join departments d on e.dept_no = d.dept_no;
eof











