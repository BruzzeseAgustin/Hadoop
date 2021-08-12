#!/bin/bash

# $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Because of some permissions checks, the container-executor binary needs to be in a path owned by root. As root, do the following:
if [ $(stat -c "%a" "$HADOOP_HOME/bin/container-executor") == "6050" ] 
then 
    echo "Files with 6050 permission: container-executor" 
else 
    echo "Changing permission: container-executor"
    chmod 6050 $HADOOP_HOME/bin/container-executor
fi 

echo 'Y' | sudo -E -u hdfs ${HADOOP_HOME}/bin/hdfs namenode -format 2>&1 | tee /opt/ranger/results/hdfs-format.log

# Create Hive db 
# Init psql
su - postgres -c 'pg_ctl -w start -D /usr/local/pgsql/data'
# Creates hive's user and database
echo "CREATE DATABASE hivemetastoredb;" | psql -U postgres
echo "CREATE DATABASE hivemetastoredb;" | psql -U postgres
echo "CREATE USER hive WITH PASSWORD 'hivemetastore';" | psql -U postgres
echo "GRANT ALL PRIVILEGES ON DATABASE hivemetastoredb TO hive;" | psql -U postgres

## Start HDFS, YARM, and MAPREDUCE daemons
# HDFS
supervisorctl start hdfs-namenode &
supervisorctl start hdfs-datanode &

# YARN
supervisorctl start yarn-nodemanager &
supervisorctl start yarn-resourcemanager &
supervisorctl start yarn-timeserver &

# HIVE
supervisorctl start hive-metastore &
supervisorctl start hive-schematool &
supervisorctl start hive-server2 &

# Tez-ui
supervisorctl start tez-ui &

# Mapred-historyserver
supervisorctl start mapred-historyserver &

# Spark-timeserver
supervisorctl start spark-timeserver &

# Zookeeper
supervisorctl start zookeeper-server &

# HBase
supervisorctl start hbase-master &
supervisorctl start hbase-regionserver &
supervisorctl start hbase-rest & 
supervisorctl start hbase-thrift &
${HADOOP_HOME}/bin/hdfs dfs -rm -R /hbase

# Atlas
supervisorctl start atlas-server &

# Create a tmp directory within the HDFS storage layer. This directory is going to store the intermediary data Hive sends to the HDFS:
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls  /tmp/hadoop-yarn/nm-local-dir); then
	printf 'folder created correctly, the output was «%s»\n' "$output"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /tmp/hadoop-yarn/nm-local-dir)
	do 
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp
	${HADOOP_HOME}/bin/hdfs dfs -chmod -R 1777 /tmp
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p  /tmp/hadoop-yarn/nm-local-dir
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp/entity-file-history/active/
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp/entity-file-history/done/
	sleep 1
	done
fi	

# Tez ui timeline server folders 
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /apps/tez); then
	printf 'folder created correctly, the output was «%s»\n' "$output"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /apps/tez)
	do 
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /apps/tez	
	${HADOOP_HOME}/bin/hdfs dfs -copyFromLocal ${TEZ_HOME}/share/tez.tar.gz /apps/tez/tez.tar.gz
	${HADOOP_HOME}/bin/hdfs dfs -copyFromLocal ${HIVE_HOME}/lib/hive-exec-3.1.2.jar /apps/tez/hive-exec-3.1.2.jar
	${HADOOP_HOME}/bin/hdfs fs -chmod -R 755 /apps/tez
	sleep 1
	done
fi

# Create the warehouse directory within the / parent directory for hive:
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /warehouse); then
	printf 'folder created correctly, the output was «%s»\n' "${output}"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /warehouse)
	do 
	printf 'some_command failed'
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /warehouse
	${HADOOP_HOME}/bin/hdfs dfs -chmod g+w  /warehouse
	sleep 1
	done
fi

# Spark libraries on hadoop namenode 
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /spark/share/lib/); then
	printf 'folder created correctly, the output was «%s»\n' "$output"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /spark/share/lib/)
	do 
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /spark/history-logs
	${HADOOP_HOME}/bin/hdfs dfs -chmod g+w  /spark/history-logs
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /spark/event-logs
	${HADOOP_HOME}/bin/hdfs dfs -chmod 777  /spark/event-logs
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /spark/share/lib/
	${HADOOP_HOME}/bin/hdfs dfs -put $SPARK_HOME/jars/*.jar /spark/share/lib/
	${HADOOP_HOME}/bin/hdfs fs -chmod -R 775 /spark/share/lib/
	sleep 1
	done
fi

# Create the ranger audit directory within the / base path:
if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /ranger/audit/); then
	printf 'folder created correctly, the output was «%s»\n' "${output}"
else
	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /ranger/audit/)
	do 
	printf 'some_command failed'
	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /ranger/audit/
	${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /ranger/audit/
	sleep 1
	done
fi


# Yarn time server folders and jars for hbase
# ${HADOOP_HOME}/bin/hdfs dfs -copyFromLocal $HADOOP_HOME/share/hadoop/yarn/timelineservice/hadoop-yarn-server-timelineservice-$HADOOP_VERSION.jar /hbase/coprocessor/hadoop-yarn-server-timelineservice.jar

# Aoid permissions problems with hbase 
# 2021-08-12 08:57:38,283 ERROR [master/localhost:16000:becomeActiveMaster] master.HMaster: Master server abort: loaded coprocessors are: [org.apache.ranger.authorization.hbase.RangerAuthorizationCoprocessor]
# hdfs dfs -rm -r /hbase
