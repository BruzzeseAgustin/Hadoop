#!/bin/bash

if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /user/tallada/input_answers); then
	printf 'folder created correctly, the output was «%s»\n' "${output}"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /user/tallada/input_answers)
	do 
	printf 'some_command failed'
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/tallada/input_answers
	sleep 1
	done
fi

# Create working directory for admin
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /user/abruzzese/); then
	printf 'folder created correctly, the output was «%s»\n' "${output}"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /user/abruzzese/)
	do 
	printf 'some_command failed'
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/abruzzese/input_answers/user_ids_names
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/abruzzese/input_names/user_ids_names
	${HADOOP_HOME}/bin/hdfs dfs -chmod g+w  /user/abruzzese/input_answers/user_ids_names
	${HADOOP_HOME}/bin/hdfs dfs -chmod g+w  /user/abruzzese/input_names/user_ids_names
	sleep 1
	done
fi

# launch a pi job
${HADOOP_HOME}/bin/hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100 2>&1 | tee /opt/ranger/results/test-admin-02_output.txt

# launch wordcount job
${HADOOP_HOME}/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount input_answers output 2>&1 | tee /opt/ranger/results/test-admin-03_output.txt

# copy results from hdfs to local
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/root/users_most_actives
${HADOOP_HOME}/bin/hdfs dfs -copyToLocal /user/root/users_most_actives /data 2>&1 | tee /opt/ranger/results/test-admin-04_output.txt
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/root/locations_most_actives 
${HADOOP_HOME}/bin/hdfs dfs -copyToLocal /user/root/locations_most_actives /data 2>&1 | tee /opt/ranger/results/test-admin-05_output.txt

# launch tez job 
hdfs dfs -mkdir -p /tmp/input/ 
hdfs dfs -mkdir -p /tmp/out/
hdfs dfs -put /opt/tools/testfiles/test.txt /tmp/input/
hadoop jar ${TEZ_HOME}/tez-examples-*.jar orderedwordcount /tmp/input/test.txt /tmp/out
hdfs dfs -cat '/tmp/out/*' 2>&1 | tee /opt/ranger/results/test-admin-06_output.txt

# launch spark job
${SPARK_HOME}/bin/spark-submit --deploy-mode cluster --class org.apache.spark.examples.SparkPi --master yarn /usr/local/spark/examples/jars/spark-examples_2.12-3.1.2.jar 10 2>&1 | tee /opt/ranger/results/test-admin-07_output.txt

${SPARK_HOME}/bin/spark-submit --deploy-mode cluster --class org.apache.spark.examples.SparkPi --master yarn /usr/local/spark/examples/src/main/python/pi.py 10 2>&1 | tee /opt/ranger/results/test-admin-08_output.txt

# launch hive job

${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -f /opt/tools/testfiles/createuser.hql 2>&1 | tee /opt/ranger/results/test-admin-09_output.txt

# ${HIVE_HOME}/bin/beeline --verbose=true -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e 'select COUNT(DISTINCT first_name) from user_test where country='UK';' 2>&1 | tee /opt/ranger/results/test-admin-09_output.txt


# NON admin user tests
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /user/tallada/input_answers); then
	printf 'folder created correctly, the output was «%s»\n' "${output}"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /user/tallada/input_answers)
	do 
	printf 'some_command failed'
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/tallada/input_answers
	sleep 1
	done
fi

su tallada -c "kinit -kt ${KEYTAB_DIR}/tallada.keytab tallada" 

su tallada -c "klist -ket ${KEYTAB_DIR}/tallada.keytab" 2>&1 | tee /opt/ranger/results/test-non_admin-00_output.txt

# Run tez,spark test 
su tallada -c "${HADOOP_HOME}/bin/hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100" 2>&1 | tee /opt/ranger/results/test-non_admin-01_output.txt

su tallada -c "${HADOOP_HOME}/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount input_answers output"

su tallada -c "${SPARK_HOME}/bin/spark-submit --deploy-mode cluster --class org.apache.spark.examples.SparkPi --master yarn /usr/local/spark/examples/jars/spark-examples_2.12-3.1.2.jar 10" 2>&1 | tee /opt/ranger/results/test-non_admin-02_output.txt

su tallada -c "${SPARK_HOME}/bin/spark-submit --deploy-mode cluster --class org.apache.spark.examples.SparkPi --master yarn /usr/local/spark/examples/src/main/python/pi.py 10" 2>&1 | tee /opt/ranger/results/test-non_admin-03_output.txt


# Add policy to hdfs
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/api/policy/ -d @/opt/ranger/policies/hdfs-policy.json 

curl -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X GET "http://localhost:6080/service/public/v2/api/policy?policyName=HomePolicy" 2>&1 | tee /opt/ranger/results/test-policy-01_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/api/policy/ -d '{ "policyName": "Test-hdfs-tallada", "resourceName": "/tmp, /user, /spark", "description": "Testing hdfs", "repositoryName": "hadoopdev", "repositoryType": "hdfs", "isEnabled": "true", "isRecursive": "true", "isAuditEnabled": "true", "permMapList": [{ "groupList": ["tallada"], "userList": ["tallada"], "permList": ["Read","Execute", "Write", "Admin"] }] } '

# Add policy to yarn
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d @/opt/ranger/policies/yarn-policy.json 

curl -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X GET "http://localhost:6080/service/public/v2/api/policy?policyName=Test-yarn-tallada" 2>&1 | tee /opt/ranger/results/test-policy-02_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d '{"service":"yarndev","name":"Test-yarn-tallada","policyType":0,"policyPriority":1,"description":"","isAuditEnabled":true,"resources":{"queue":{"values":["root.default","root.spark"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"submit-app","isAllowed":true},{"type":"admin-queue","isAllowed":true}],"users":["tallada"],"groups":["tallada"],"roles":[],"conditions":[],"delegateAdmin":true}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"yarn","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}'

# Wait to make the uploaded/updated policy valid
sleep 30 

# Run tez,spark test 
# hdfs jobs
su tallada -c "${HADOOP_HOME}/bin/hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100" 2>&1 | tee /opt/ranger/results/test-non_admin-04_output.txt

su tallada -c "${HADOOP_HOME}/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount input_answers output" 2>&1 | tee /opt/ranger/results/test-non_admin-05_output.txt

# tez jobs
su tallada -c "hadoop jar ${TEZ_HOME}/tez-examples-*.jar orderedwordcount /tmp/input/test.txt /tmp/out"
su tallada -c "hdfs dfs -cat '/tmp/out/*'" >&1 | tee /opt/ranger/results/test-non_admin-06_output.txt

# spark jobs
su tallada -c "${SPARK_HOME}/bin/spark-submit --deploy-mode cluster --class org.apache.spark.examples.SparkPi --master yarn /usr/local/spark/examples/jars/spark-examples_2.12-3.1.2.jar 10" 2>&1 | tee /opt/ranger/results/test-non_admin-07_output.txt

su tallada -c "${SPARK_HOME}/bin/spark-submit --deploy-mode cluster --class org.apache.spark.examples.SparkPi --master yarn /usr/local/spark/examples/src/main/python/pi.py 10" 2>&1 | tee /opt/ranger/results/test-non_admin-08_output.txt

# Run hive test
su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "CREATE DATABASE IF NOT EXISTS TRAINING;"' 2>&1 | tee /opt/ranger/results/test-non_admin-09_output.txt

 su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DROP DATABASE IF EXISTS TRAINING;"' 2>&1 | tee /opt/ranger/results/test-non_admin-10_output.txt

# Allow drop policy for database and user tallada
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d @/opt/ranger/policies/hive-policy-tallada-db-drop.json 2>&1 | tee /opt/ranger/results/test-policy-03_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d '{"service": "hivedev", "name": "Test-Tallada-Training", "policyType": 0, "policyPriority": 0, "description": "", "isAuditEnabled": true, "resources": { "database": { "values": [ "training"], "isExcludes": false, "isRecursive": false } }, "policyItems": [ { "accesses": [ { "type": "drop", "isAllowed": true } ], "users": [ "tallada" ], "groups": [], "roles": [], "conditions": [], "delegateAdmin": false } ], "denyPolicyItems": [], "allowExceptions": [], "denyExceptions": [], "dataMaskPolicyItems": [], "rowFilterPolicyItems": [],"serviceType": "hive", "options": {}, "validitySchedules": [], "policyLabels": [], "zoneName": "", "isDenyAllElse": false, "isEnabled": true, "version": 1 }'

# Wait to make the uploaded/updated policy valid
sleep 25 

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DROP DATABASE IF EXISTS TRAINING;"' >> /opt/ranger/results/test-non_admin-11_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "CREATE TABLE IF NOT EXISTS test(col1 char(10),col2 char(20));"' >> /opt/ranger/results/test-non_admin-12_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DROP TABLE test;"' 2>&1 | tee /opt/ranger/results/test-non_admin-13_output.txt

# Allow drop policy for table and user tallada
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d @/opt/ranger/policies/hive-policy-tallada-table-drop.json 2>&1 | tee /opt/ranger/results/test-policy-04_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d '{ "service": "hivedev", "name": "Test-Tallada-Table", "policyType": 0, "policyPriority": 0, "description": "", "isAuditEnabled": true, "resources": { "database": { "values": [ "default" ], "isExcludes": false, "isRecursive": false }, "table": { "values": [ "test" ], "isExcludes": false, "isRecursive": false } }, "policyItems": [ { "accesses": [ { "type": "drop", "isAllowed": true } ], "users": [ "tallada" ], "groups": [], "roles": [], "conditions": [], "delegateAdmin": false } ], "denyPolicyItems": [], "allowExceptions": [], "denyExceptions": [], "dataMaskPolicyItems": [], "rowFilterPolicyItems": [], "serviceType": "hive", "options": {}, "validitySchedules": [], "policyLabels": [], "zoneName": "", "isDenyAllElse": false, "guid": "bf03cee6-4cc6-4ce7-a967-53186f75b585", "isEnabled": true, "version": 1}'

# Wait to make the uploaded/updated policy valid
sleep 25 

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DROP TABLE test;"' 2>&1 | tee /opt/ranger/results/test-non_admin-14_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "CREATE TABLE IF NOT EXISTS test(col1 char(10),col2 char(20));"' 2>&1 | tee /opt/ranger/results/test-non_admin-15_output.txt

# Alter
su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "ALTER TABLE test ADD COLUMNS(col5 char(10));"' 2>&1 | tee /opt/ranger/results/test-non_admin-16_output.txt

# Search for policy id: 
testidp=$(curl -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X GET "http://localhost:6080/service/public/v2/api/policy?policyName=Test-Tallada-Table" | jq -r '.[].id') 

# Update given policy : 
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X PUT http://localhost:6080/service/public/v2/api/policy/$testidp -d @/opt/ranger/policies/hive-policy-tallada-table-update.json 2>&1 | tee /opt/ranger/results/test-policy-05_output.txt 

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X PUT http://localhost:6080/service/public/v2/api/policy/$testidp -d '{ "service": "hivedev", "name": "Test-Tallada-Table", "policyType": 0, "policyPriority": 0, "description": "", "isAuditEnabled": true, "resources": { "database": { "values": [ "default" ], "isExcludes": false, "isRecursive": false }, "table": { "values": [ "test" ], "isExcludes": false, "isRecursive": false } }, "policyItems": [ { "accesses": [ { "type": "drop", "isAllowed": true }, { "type": "alter", "isAllowed": true } ], "users": [ "tallada" ], "groups": [], "roles": [], "conditions": [], "delegateAdmin": false } ], "denyPolicyItems": [], "allowExceptions": [], "denyExceptions": [], "dataMaskPolicyItems": [], "rowFilterPolicyItems": [], "serviceType": "hive", "options": {}, "validitySchedules": [], "policyLabels": [], "zoneName": "", "isDenyAllElse": false, "guid": "bf03cee6-4cc6-4ce7-a967-53186f75b585", "isEnabled": true, "version": 1}'

# Wait to make the uploaded/updated policy valid
sleep 25

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "ALTER TABLE test ADD COLUMNS(col3 char(10),col4 char(10));"' 2>&1 | tee /opt/ranger/results/test-non_admin-14_output.txt

# Select
su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "CREATE TABLE IF NOT EXISTS student( Student_Name STRING, Student_Rollno INT, Student_Marks FLOAT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ",";"' 2>&1 | tee /opt/ranger/results/test-non_admin-15_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -f /opt/tools/testfiles/createuser.hql' 2>&1 | tee /opt/ranger/results/test-non_admin-16_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DESC user_test;"' 2>&1 | tee /opt/ranger/results/test-non_admin-17_output.txt

# Allow Description policy for table users and tallada
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d @/opt/ranger/policies/hive-policy-tallada-table-select.json 2>&1 | tee /opt/ranger/results/test-policy-06_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d '{"isEnabled":true,"version":3,"service":"hivedev","name":"Test-Tallada-Select","policyType":0,"policyPriority":0,"description":"","isAuditEnabled":true,"resources":{"database":{"values":["default"],"isExcludes":false,"isRecursive":false},"column":{"values":["*"],"isExcludes":false,"isRecursive":false},"table":{"values":["user_test"],"isExcludes":false,"isRecursive":false}},"policyItems":[{"accesses":[{"type":"select","isAllowed":true},{ "type": "drop", "isAllowed": true }],"users":["tallada"],"groups":[],"roles":[],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hive","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}'

# Wait to make the uploaded/updated policy valid
sleep 25

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DESC user_test;"' 2>&1 | tee /opt/ranger/results/test-non_admin-18_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -e "DROP TABLE user_test;"' 2>&1 | tee /opt/ranger/results/test-non_admin-19_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -f /opt/tools/testfiles/createhistory.hql' 2>&1 | tee /opt/ranger/results/test-non_admin-20_output.txt

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -f /opt/tools/testfiles/loadhistory.hql' 2>&1 | tee /opt/ranger/results/test-non_admin-21_output.txt

# Allow Load into table policy for table users and tallada
curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d @/opt/ranger/policies/hive-policy-tallada-table-load.json 2>&1 | tee /opt/ranger/results/test-policy-07_output.txt

# curl -iv -u admin:s3cUr1tyr4Ng3r -H "Content-Type: application/json" -X POST http://localhost:6080/service/public/v2/api/policy/ -d '{"isEnabled":true,"version":1,"service":"hivedev","name":"Test-Tallada-History","policyType":0,"policyPriority":0,"description":"","isAuditEnabled":true,"resources":{"database":{"values":["default"],"isExcludes":false,"isRecursive":false},"table":{"values":["history_raw"],"isExcludes":false,"isRecursive":false}},"policyItems":[{"accesses":[{"type":"update","isAllowed":true}],"users":["tallada"],"groups":[],"roles":[],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hive","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}'

# Wait to make the uploaded/updated policy valid
sleep 25

su tallada -c '${HIVE_HOME}/bin/beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/_HOST@EXAMPLE.COM" -f /opt/tools/testfiles/loadhistory.hql' 2>&1 | tee /opt/ranger/results/test-non_admin-22_output.txt
