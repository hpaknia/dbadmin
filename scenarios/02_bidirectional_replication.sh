#!/usr/bin/env bash

source $DIR/actions/05_latin1_tables.sh

source $DIR/actions/06_fill_latin1_data_mysql1.sh
source $DIR/actions/07_fill_in_employees_db.sh

source $DIR/actions/02_replicate_mysql1_to_mysql2.sh
source $DIR/actions/09_replicate_mysql2_to_mysql1.sh

source $DIR/actions/08_backup.sh
