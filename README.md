# DB Admin

### Prerequisite
Make sure you have docker installed. Scripts are tested in Mac OS, so they should work fine in linux based systems.
You should have mysql client and mysql_config_editor installed on your machine. I will soon remove this depepndency by running the commands from a centos container.

### Quick Start
Run `./run.sh`
It will bring up two mysql 5.7.22 instances: `mysql1` on port `33061` and as you guessed `33062` for `mysql2`.

First one master and the other slave.

The script asks for the passwords to create login path. Password is same as user names. There are `root` and `nonroot` users for each database.

Slave is readonly.

The script fills the master with a table `dba.x` and it should be replicated on slave.

Then script tries to delete data on slave which it fails as expected.

The charset of `mysql1` is utf8 and the slave is `latin1`. But the tables while they are replicated are utf8. 

Containers go away when the script is finished or failed.
