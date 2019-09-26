#!/usr/bin/env bash

source $DIR/actions/05_latin1_tables.sh

source $DIR/actions/06_fill_latin1_data_mysql1.sh
source $DIR/actions/07_fill_in_employees_db.sh

# source $DIR/actions/08_backup.sh

source $DIR/actions/10_bidirectional_replication_gtid.sh
source $DIR/actions/11_break_bidirectional_replication.sh
source $DIR/actions/12_fix_bidirectional_replication.sh

