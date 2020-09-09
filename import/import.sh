#!/bin/bash

system_name="";
currentDir=`pwd`

importCiData(){
  echo "import "`echo ${system_name}/08_*.csv`" start..."
  sudo docker run -v ${currentDir}:/etc/newman postman/newman run import_ci_data.postman_collection.json -e wecube.postman_environment.json -d ${system_name}/08_*.csv
  echo "import "`echo ${system_name}/08_*.csv`" finished"
  for i in {36..51}  
  do
      echo "import "`echo ${system_name}/${i}_*.csv`" start..."
      sudo docker run -v ${currentDir}:/etc/newman postman/newman  run import_ci_data.postman_collection.json -e wecube.postman_environment.json -d ${system_name}/${i}_*.csv
      echo "import "`echo ${system_name}/${i}_*.csv`" finished."
  done
  echo "import "`echo ${system_name}/55_*.csv`" start..."
  sudo docker run -v ${currentDir}:/etc/newman postman/newman  run import_ci_data.postman_collection.json -e wecube.postman_environment.json -d ${system_name}/55_*.csv
  echo "import "`echo ${system_name}/55_*.csv`" finished"
}


case "$1" in
  ALL)
    system_name=UM
    importCiData

    system_name=FPS
    importCiData

    system_name=IFPS
    importCiData

    system_name=WEMQ
    importCiData

    system_name=RMB
    importCiData

    system_name=WEREDIS
    importCiData

    system_name=GNS
    importCiData

    system_name=ECIF
    importCiData

    system_name=MSS
    importCiData
    ;;
  UM)
    system_name=UM
    importCiData
    ;;
  FPS)
    system_name=FPS
    importCiData
    ;;    
  IFPS)
    system_name=IFPS
    importCiData
    ;;
  WEMQ)
    system_name=WEMQ
    importCiData
    ;;
  RMB)
    system_name=RMB
    importCiData
    ;;
  WEREDIS)
    system_name=WEREDIS
    importCiData
    ;;
  GNS)
    system_name=GNS
    importCiData
    ;;
  ECIF)
    system_name=ECIF
    importCiData
    ;;
  MSS)
    system_name=MSS
    importCiData
    ;;
  *)
    system_name=$1
    importCiData
    ;;
esac
