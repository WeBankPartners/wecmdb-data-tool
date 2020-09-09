#!/bin/bash

MYSQL=`which mysql`
systemName=$1
subsysName=$2
envCode=$3
extractDbName=$4
extractDbPwd=$5

currentDir=`pwd`
dataDir=${currentDir}/${subsysName}

echo "Create new directory [${subsysName}] for storage ${subsysName} subsystem data..."
mkdir -p ${dataDir}

echo "Clear last CSV files..."
rm -f /data/extract/mysql-files/*.csv

sql1="drop table if exists tmp_unit_design;create table tmp_unit_design (\`guid\` VARCHAR(15) NOT NULL COMMENT '全局唯一ID', \`key_name\` VARCHAR(1000) NULL DEFAULT NULL COMMENT '唯一名称', PRIMARY KEY (\`guid\`) ) COLLATE='utf8_general_ci' ENGINE=InnoDB;"
sql2="insert into tmp_unit_design  select distinct c.guid,c.key_name from  app_system_design f left join subsys_design e on 
 e.app_system_design=f.guid left join unit_design c  on  c.subsys_design=e.guid where f.key_name='${systemName}'  and e.key_name='${subsysName}' ;"

sql3="ALTER TABLE \`deploy_package\$diff_conf_variable\` ADD INDEX \`Index 2\` (\`to_guid\`);"
sql4="ALTER TABLE \`deploy_package\$diff_conf_variable\` ADD INDEX \`Index 3\` (\`from_guid\`);"

sql5="drop table if exists tmp_unit;create table  tmp_unit (\`guid\` VARCHAR(15) NOT NULL COMMENT '全局唯一ID', \`key_name\` VARCHAR(1000) NULL DEFAULT NULL COMMENT '唯一名称',\`env_code\` VARCHAR(1000) NULL DEFAULT NULL COMMENT '部署环境', PRIMARY KEY (\`guid\`) ) COLLATE='utf8_general_ci' ENGINE=InnoDB;"
sql6="insert into tmp_unit  select distinct c.guid,c.key_name,v.key_name from deploy_environment v , subsys_design s ,  app_system f left join subsys e on  e.app_system=f.guid left join unit c  on  c.subsys=e.guid where  s.guid=e.subsys_design  and v.guid=f.deploy_environment  and s.key_name='${subsysName}' and v.code='${envCode}' ;"


#应用系统设计
sql37="select 'ci_type_id','key_name@application_domain','app_system_design_id','code','key_name@data_center_design','description','name' union all select distinct 37,b.key_name,a.app_system_design_id,a.code,c.key_name,a.description,a.name from app_system_design a, application_domain b,data_center_design c where a.application_domain=b.guid and a.data_center_design=c.guid and a.guid=a.r_guid and a.key_name='${systemName}' into outfile '/var/lib/mysql-files/36_37.app_system_design.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"

#子系统设计
sql38="select 'ci_type_id','key_name@app_system_design','key_name@@business_zone_design','code','description','name','subsys_design_id','key_name@network_zone_design' union all  select distinct 38,f.key_name,g.key_name,e.code,e.description,e.name,e.subsys_design_id,  h.key_name from  subsys_design e, app_system_design f, subsys_design\$business_zone_design r, business_zone_design g,network_zone_design h  where e.app_system_design=f.guid and e.guid=r.from_guid and r.to_guid=g.guid and e.guid=e.r_guid  and h.guid=e.network_zone_design and f.key_name='${systemName}'  and e.key_name='${subsysName}'  into outfile '/var/lib/mysql-files/37_38.subsys_design.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"

#单元设计
sql39="select 'ci_type_id','across_resource_set','code','description','name','protocol','key_name@resource_set_design','key_name@subsys_design','key_name@unit_type','white_list_type' union all select distinct 39,c.across_resource_set,c.code,c.description,c.name,c.protocol,r.key_name,e.key_name,u.key_name,c.white_list_type from  app_system_design f left join subsys_design e on  e.app_system_design=f.guid left join unit_design c  on  c.subsys_design=e.guid left join resource_set_design r on c.resource_set_design=r.guid left join unit_type u on c.unit_type=u.guid  where f.key_name='${systemName}'  and e.key_name='${subsysName}'  into outfile '/var/lib/mysql-files/38_39.unit_design.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"

#调用设计
sql40="select 'ci_type_id','description','key_name@unit_design.invoked_unit_design','invoke_type','key_name@unit_design.invoke_unit_design','key_name@resource_set_invoke_design' union all select distinct 40,a.description,b.key_name,a.invoke_type,c.key_name,d.key_name from invoke_design a,unit_design b,unit_design c,resource_set_invoke_design d ,tmp_unit_design t  where a.invoked_unit_design=b.guid and a.invoke_unit_design=c.guid and a.guid=a.r_guid and a.resource_set_invoke_design=d.guid and  c.guid= t.guid  into outfile '/var/lib/mysql-files/39_40.invoke_design.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"

#应用系统
sql46="select 'ci_type_id','code','key_name@app_system_design','key_name@@data_center','key_name@deploy_environment','description','key_name@legal_person' union all select distinct 46,a.code,b.key_name,c.key_name,d.key_name,a.description,e.key_name from app_system a,app_system_design b, data_center c, app_system\$data_center c1, deploy_environment d, legal_person e where a.app_system_design=b.guid and a.guid=c1.from_guid and c1.to_guid=c.guid and a.deploy_environment=d.guid and a.legal_person=e.guid and b.key_name = '${systemName}' and d.code='${envCode}' into outfile '/var/lib/mysql-files/44_46.app_system.csv' fields terminated by ','  ENCLOSED BY '\"'   lines terminated by '\r\n' ;"

#子系统
sql47="select 'ci_type_id','key_name@app_system','key_name@@business_zone','description','key_name@manage_role','key_name@subsys_design','key_name@network_zone' union all select distinct 47,b.key_name,c.key_name,a.description,d.key_name,e.key_name,f.key_name from subsys a, app_system b, business_zone c, subsys\$business_zone c1,manage_role d, subsys_design e,network_zone f,deploy_environment v where  a.app_system=b.guid and a.guid=c1.from_guid and c1.to_guid=c.guid and a.manage_role=d.guid and a.subsys_design=e.guid  and a.network_zone=f.guid and a.guid=a.r_guid  and b.deploy_environment=v.guid and v.code='${envCode}' and e.key_name='${subsysName}' into outfile '/var/lib/mysql-files/45_47.subsys.csv' fields terminated by ','  ENCLOSED BY '\"'   lines terminated by '\r\n' ;"

#单元
sql48="select 'ci_type_id','code','description','key_name@manage_role','public_key','key_name@resource_set','security_group_asset_id','key_name@subsys','key_name@unit_design','custom_script' union all select distinct 48,a.code,a.description,c.key_name,a.public_key,d.key_name, a.security_group_asset_id,e.key_name,f.key_name,a.custom_script from resource_set d,subsys e, unit_design f,  tmp_unit t,  unit a left join manage_role c on  a.manage_role=c.guid  where  a.resource_set=d.guid and a.subsys=e.guid and a.unit_design=f.guid  and t.guid=a.guid into outfile '/var/lib/mysql-files/46_48.unit.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"

#调用
sql49="select 'ci_type_id','description','key_name@unit.invoked_unit','key_name@invoke_design','key_name@unit.invoke_unit' union all select distinct 49,a.description,b.key_name,c.key_name,d.key_name from invoke a, unit b, invoke_design c, unit d ,tmp_unit t where a.invoked_unit=b.guid and a.invoke_design=c.guid and a.invoke_unit=d.guid and a.guid=a.r_guid and d.guid=t.guid  into outfile '/var/lib/mysql-files/47_49.invoke.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"

#应用实例
sql50="select 'ci_type_id','cpu','deploy_package_url','deploy_user_password','description','install_args','install_dir','memory','monitor_port','name','port','storage','key_name@unit','deploy_user','rw_dir' union all select distinct 50,a.cpu,'','Abcd1234',a.description,IFNULL(a.install_args,''),IFNULL(a.install_dir,''),a.memory,a.monitor_port,a.name,a.port,a.storage,d.key_name,a.deploy_user,a.rw_dir from app_instance a, host_resource_instance c, unit d ,tmp_unit t where a.host_resource_instance=c.guid and a.unit=d.guid and a.guid=a.r_guid and  d.guid=t.guid  into outfile '/var/lib/mysql-files/48_50.app_instance.csv' fields terminated by ','  ENCLOSED BY '\"'   lines terminated by '\r\n' ;"

#数据库实例
sql51="select 'ci_type_id','cpu','deploy_backup_asset_id','deploy_user','deploy_user_password','memory','name','port','regular_backup_asset_id','storage','key_name@unit' union all select distinct 51,a.cpu,a.deploy_backup_asset_id,a.deploy_user,'webank@12345', a.memory,a.name,a.port,a.regular_backup_asset_id,a.storage,d.key_name from rdb_instance a, deploy_package b, rdb_resource_instance c, unit d ,tmp_unit t where a.deploy_package=b.guid and a.rdb_resource_instance=c.guid and a.unit=d.guid and a.guid=a.r_guid and d.guid=t.guid into outfile '/var/lib/mysql-files/49_51.rdb_instance.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n'  ;"
sql51="select 'ci_type_id','cpu','deploy_backup_asset_id','deploy_user','deploy_user_password','memory','name','port','regular_backup_asset_id','storage','key_name@unit' union all select distinct 51,a.cpu,a.deploy_backup_asset_id,a.deploy_user,'webank@12345', a.memory,a.name,a.port,a.regular_backup_asset_id,a.storage,d.key_name from rdb_instance a, unit d ,tmp_unit t where a.unit=d.guid and a.guid=a.r_guid and d.guid=t.guid into outfile '/var/lib/mysql-files/49_51.rdb_instance.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n'  ;"

#负载均衡实例
sql53="select 'ci_type_id','name','key_name@unit','port','key_name@unit' union all select distinct 53,a.name,a.unit,a.port,b.key_name from lb_instance a, unit b, tmp_unit t where a.unit=b.guid and b.guid=t.guid into outfile '/var/lib/mysql-files/51_53.lb_instance.csv' fields terminated by ','  ENCLOSED BY '\"'  lines terminated by '\r\n' ;"



################################
#差异化配置
sql44="select 'ci_type_id','code','description','variable_name','variable_value' union all select distinct '44',a.code as code,IFNULL(a.description,''), a.variable_name as name,concat('\"',replace(a.variable_value,'\"','\"\"'),'\"') as variable_value from 
  tmp_unit_design t  left join  deploy_package b on b.unit_design=t.guid 
left join deploy_package\$diff_conf_variable b1  on b.guid=b1.from_guid left join  diff_configuration a on b1.to_guid=a.guid 
 where  a.key_name is not null into outfile '/var/lib/mysql-files/08_44.diff_configuration.csv' fields terminated by ','  lines terminated by '\r\n' ;"

#静态差异化值
sql64="select 'ci_type_id','code','deploy_environment_difference','description','static_value','key_name@deploy_environment','key_name@unit_design' union all  select distinct 64, a.code,a.deploy_environment_difference,a.description,concat('\"',replace(a.static_value,'\"','\"\"'),'\"') as static_value,b.key_name,c.key_name  from  tmp_unit_design c  left join  static_diff_conf_value a on a.unit_design=c.guid   left join deploy_environment b on   a.deploy_environment=b.guid where  a.guid=a.r_guid  and a.key_name is not null  into outfile '/var/lib/mysql-files/55_64.static_diff_conf_value.csv' fields terminated by ','  lines terminated by '\r\n' ;"

echo "Start to extract data to CSV files..."
$MYSQL -h127.0.0.1 -P3306 -uroot -p${extractDbPwd} --database ${extractDbName} <<EOF
${sql1}
${sql2}
${sql3}
${sql4}
${sql5}
${sql6}

${sql37}
${sql38}
${sql39}
${sql40}
${sql46}
${sql47}
${sql48}
${sql49}
${sql50}
${sql51}
${sql53}

${sql44}
${sql64}
EOF
echo "Extract data to CSV files success !"

mv /data/extract/mysql-files/*.csv ${dataDir}

echo "Start to convert data..."
cd ${dataDir}
sed -i 's/\\,/,/g' 08_44.diff_configuration.csv
sed -i 's/\\\\/\\/g' 08_44.diff_configuration.csv
sed -i 's/\\\\/\\/g' 46_48.unit.csv
#sed -i 's/FPS_TP_APP-->--FPS_HBASE_APP/FPS_TP_MASTER-->--FPS_HBASE_MASTER/g' 47_49.invoke.csv
#sed -i 's/FPS_TP_APP-->--UM_SRV_LB/FPS_TP_MASTER-->--UM_SRV_LB/g' 47_49.invoke.csv
#sed -i 's/FPS_TP_LB-->--FPS_TP_APP/FPS_TP_MASTERLB-->--FPS_TP_MASTER/g' 47_49.invoke.csv

echo "Convert data success !"

echo "Extract data for ENV[${envCode}] SUBSYSTEM[${subsysName}] into [${dataDir}] success !"
