#!/usr/bin/env bash

echo creating table and data in mysql1 latin1

mysql --login-path=root1 << eof

USE dba;

--
-- Dumping data for table x
--

LOCK TABLES x WRITE;
/*!40000 ALTER TABLE x DISABLE KEYS */;
INSERT INTO x VALUES (1,'dba','dba'),(2,'hassan','paknia'),(3,'Clement','IDK'),(null,'dba','dba');
/*!40000 ALTER TABLE x ENABLE KEYS */;
UNLOCK TABLES;


eof

