#!/bin/bash
if [ $# -lt 3 ]
  then
    echo "Usage: `basename $0` SYSTEM_NAME ENV_CODE EXTRACT_DB_NAME(option) "
    exit 1
fi

systemName=$1
subsysName=$2
envCode=$3
STG_PWD=Abcd1234
EXTRACT_DB=${4:-extract_db}
EXTRACT_DB_PWD=Wecube@1234
echo "Extract data from 172.21.0.106:3306 ..."

sh 01.dump-db-from-stg.sh ${STG_PWD} ${EXTRACT_DB} ${EXTRACT_DB_PWD}
sh 02.reset-data.sh ${EXTRACT_DB} ${EXTRACT_DB_PWD}
sh 03.extract-data.sh ${systemName} ${subsysName} ${envCode} ${EXTRACT_DB} ${EXTRACT_DB_PWD}
