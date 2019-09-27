#!/usr/bin/env bash

# we don't want to stop the script if the comparison fails
set +e
mysqldbcompare --server1=root1 --server2=root2 --all
set -e
