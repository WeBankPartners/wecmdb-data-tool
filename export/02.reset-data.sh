#!/bin/bash

EXTRACT_DB=$1
EXTRACT_DB_PWD=$2
pwd=`pwd`

echo "Start to reset data..."

mysql -h127.0.0.1 -P3306 -uroot -p${EXTRACT_DB_PWD} --database ${EXTRACT_DB}  <<EOF
source ${pwd}/reset-data.sql;
EOF

echo "Reset data success !"
