#!/bin/bash

## Add policy and manager services 
# Link: https://community.cloudera.com/t5/Support-Questions/Ranger-Add-Policies-via-REST-API/td-p/130311
# Link: https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=65877425
# Link: https://www.ibm.com/support/pages/ranger-restapis-creating-updating-deleting-and-searching-policies-big-sql-hadoop-dev
# Link: https://pierrevillard.com/tag/apache-ranger/
# Link: https://github.com/abajwa-hw/security-workshops/blob/master/Setup-ranger-23.md


# HDFS
curl -i -X POST -H "Content-type:application/json" -H "Accept:application/json" -u admin:s3cUr1tyr4Ng3r http://localhost:6080/service/public/v2/api/service -d @/opt/ranger/policies/hdfs-service.json  2>&1 | tee /opt/ranger/results/test-service-01_output.txt

# curl -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST -d '{"configs": {"password": "s3cUr1tyr4Ng3r","username": "rangerlookup", "hadoop.security.authorization": "true", "hadoop.security.authentication": "kerberos","dfs.datanode.kerberos.principal": "hdfs/_HOST@EXAMPLE.COM","dfs.namenode.kerberos.principal": "hdfs/_HOST@EXAMPLE.COM","dfs.secondary.namenode.kerberos.principal": "hdfs/_HOST@EXAMPLE.COM","fs.default.name": "hdfs://localhost:9000","tag.download.auth.users":"hdfs","policy.download.auth.users":"hdfs"},"description":"hdfsservice","isEnabled": true,"name": "hadoopdev","type": "hdfs","version": 1}' http://localhost:6080/service/public/v2/api/service

# YARN
curl -i -X POST -H "Content-type:application/json" -H "Accept:application/json" -u admin:s3cUr1tyr4Ng3r http://localhost:6080/service/public/v2/api/service -d @/opt/ranger/policies/yarn-service.json  2>&1 | tee /opt/ranger/results/test-service-02_output.txt

# curl -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST -d '{"configs":{"password": "s3cUr1tyr4Ng3r","username": "rangerlookup", "tag.download.auth.users":"yarn","policy.download.auth.users":"yarn", "hadoop.security.authentication": "kerberos", "password":"s3cUr1tyr4Ng3r", "yarn.url":"http://localhost:8088"},"type":"yarn","name":"yarndev","displayName":"yarndev","description":"yarn service manager"}'  http://localhost:6080/service/public/v2/api/service

# HIVE
curl -i -X POST -H "Content-type:application/json" -H "Accept:application/json" -u admin:s3cUr1tyr4Ng3r http://localhost:6080/service/public/v2/api/service -d @/opt/ranger/policies/hive-service.json  2>&1 | tee /opt/ranger/results/test-service-03_output.txt

#curl -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST -d '{"type":"hive","name":"hivedev","displayName":"hivedev","description":"","configs":{"password":"s3cUr1tyr4Ng3r","jdbc.driverClassName":"org.apache.hive.jdbc.HiveDriver","jdbc.url":"jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM","username":"rangerlookup", "tag.download.auth.users":"hive","policy.download.auth.users":"hive"}}'  http://localhost:6080/service/public/v2/api/service

# HBASE 
curl -i -X POST -H "Content-type:application/json" -H "Accept:application/json" -u admin:s3cUr1tyr4Ng3r http://localhost:6080/service/public/v2/api/service -d @/opt/ranger/policies/hbase-service.json  2>&1 | tee /opt/ranger/results/test-service-04_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/service -d '{"type":"hbase","name":"hbasedev","displayName":"hbasedev","description":"","configs":{"hbase.zookeeper.quorum":"localhost","tag.download.auth.users":"hbase","password":"s3cUr1tyr4Ng3r","policy.download.auth.users":"hbase","hadoop.security.authentication":"kerberos","hbase.security.authentication":"kerberos","hbase.zookeeper.property.clientPort":"2181","zookeeper.znode.parent":"/hbase","hbase.master.kerberos.principal":"hbase/_HOST@EXAMPLE.COM","username":"rangerlookup"}, "tag.download.auth.users":"hbase","policy.download.auth.users":"hbase"}'

# Atlas
curl -i -X POST -H "Content-type:application/json" -H "Accept:application/json" -u admin:s3cUr1tyr4Ng3r http://localhost:6080/service/public/v2/api/service -d @/opt/ranger/policies/atlas-service.json  2>&1 | tee /opt/ranger/results/test-service-05_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/service -d '{"isEnabled":true,"createdBy":"Admin","updatedBy":"Admin", "type":"atlas","name":"atlasdev","displayName":"atlasdev","description":"","configs":{"atlas.rest.address":"http://localhost:21000","password":"admin","username":"admin"}, "tag.download.auth.users":"atlas","policy.download.auth.users":"atlas"}'
