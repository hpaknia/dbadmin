#!/usr/bin/env bash

# source $DIR/actions/01_utf8_to_latin1.sh
source $DIR/actions/05_latin1_tables.sh

# source $DIR/actions/05_latin1_tables.sh
source $DIR/actions/06_fill_latin1_data_mysql1.sh

source $DIR/actions/02_replicate_mysql1_to_mysql2.sh

source $DIR/actions/07_fill_in_employees_db.sh

# source $DIR/actions/03_fill_utf8_data_mysql1.sh

# source $DIR/actions/04_delete_mysql2_data.sh

source $DIR/actions/08_backup.sh
