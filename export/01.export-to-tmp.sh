#!/bin/bash

STG_PWD=$1
EXTRACT_DB=$2
EXTRACT_DB_PWD=$3

echo "Creating extract database..."
mysql -h127.0.0.1 -uroot -p${EXTRACT_DB_PWD} << EOF
drop database if exists ${EXTRACT_DB};
create database ${EXTRACT_DB};
EOF

echo "Dump database from wecmdb db to extract db..."
mysqldump wecmdb_embedded -h127.0.0.1 -uroot -p${STG_PWD} --add-drop-table | mysql -h127.0.0.1 ${EXTRACT_DB} -uroot -p${EXTRACT_DB_PWD}

echo "Import to extract db success !!"
