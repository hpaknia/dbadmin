use dba;
set names utf8;
create table if not exists x (
	id int auto_increment Primary Key, 
	name varchar(200) default null, 
	original varchar(200) default null
);
set names utf8;
INSERT INTO `x` (`id`, `name`, `original`)
VALUES
	(1, 'dba', 'dba'),
	(2, 'hassan', 'حسن'),
	(null, 'Clement', 'मेहरबान'),
	(20, 'dba', 'dba');
