#!/bin/bash

#$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Create the ranger warehouse directory within the / base path:
# if output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /ranger/audit/); then
# 	printf 'folder created correctly, the output was «%s»\n' "${output}"
# else
# 	while ! output=$(${HADOOP_HOME}/bin/hdfs dfs -ls /ranger/audit/)
# 	do 
# 	printf 'some_command failed'
# 	${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /ranger/audit/
# 	${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /ranger/audit/
# 	sleep 1
# 	done
# fi

# Create Ranger db 
# Init psql
su - postgres -c 'pg_ctl -w start -D /usr/local/pgsql/data'
# Create ranger's user and database
echo "CREATE USER ranger WITH PASSWORD 's3cUr1tyr4Ng3r';" | psql -U postgres
echo "CREATE USER rangerlogger WITH PASSWORD 's3cUr1tyr4Ng3r';" | psql -U postgres
echo "CREATE USER rangerusersync WITH PASSWORD 's3cUr1tyr4Ng3r';" | psql -U postgres
echo "CREATE USER rangeradmin WITH PASSWORD 's3cUr1tyr4Ng3r';" | psql -U postgres
echo "CREATE USER admin WITH PASSWORD 's3cUr1tyr4Ng3r';" | psql -U postgres
echo "CREATE DATABASE rangerdb;" | psql -U postgres
echo "GRANT ALL PRIVILEGES ON DATABASE rangerdb to admin;" | psql -U postgres
echo "GRANT ALL PRIVILEGES ON DATABASE rangerdb to ranger;" | psql -U postgres

# Ranger plugins
cd ${RANGER_HOME}
./setup.sh >> /var/log/hadoop-ranger/hadoop-ranger-admin-setup.log 
./set_globals.sh >> /var/log/hadoop-ranger/hadoop-ranger-admin-globals.log  
# ranger-admin start >> /var/log/hadoop-ranger/hadoop-ranger-admin-run.log &
supervisorctl start ranger-admin 

# Ranger Usersync
cd ${RANGER_USER_HOME}
./setup.sh >> /var/log/hadoop-ranger/hadoop-ranger-usersync-setup.log
./ranger-usersync start >> /var/log/hadoop-ranger/hadoop-ranger-usersync-start.log
 
cd ${RANGER_HDFS_HOME}
./enable-hdfs-plugin.sh >> /var/log/hadoop-ranger/hadoop-ranger-hdfs-setup.log 
# Ranger Plugin for hadoop has been enabled. Please restart hadoop to ensure that changes are effective.
# supervisorctl restart hdfs-datanode
# supervisorctl restart hdfs-namenode

cd ${RANGER_YARN_HOME}
mkdir -pv /var/log/yarn/audit/hdfs/spool
mkdir -pv /var/log/hadoop/yarn/audit/hdfs/spool
chown -R yarn:hadoop /var/log/yarn/
mkdir -pv /var/log/hadoop/audit/hdfs/spool
mkdir -pv /var/log/hadoop/hdfs/audit/hdfs/spool
chown -R hdfs:hadoop /var/log/hadoop/
./enable-yarn-plugin.sh >> /var/log/hadoop-ranger/hadoop-ranger-yarn-setup.log
# Ranger Plugin for yarn has been enabled. Please restart yarn to ensure that changes are effective.
# supervisorctl restart yarn-nodemanager 
# supervisorctl restart yarn-resourcemanager
# supervisorctl restart yarn-timeserver

cd ${RANGER_HIVE_HOME}
# If /var/log/hive directory does not exist then create one and give required rights to user hive.
mkdir -p /var/log/hive/audit/hdfs/spool
chown -R hive:hadoop /var/log/hive
./enable-hive-plugin.sh >> /var/log/hadoop-ranger/hadoop-ranger-hive-setup.log
# Ranger Plugin for hive has been enabled. Please restart hive to ensure that changes are effective.
ln -sfn ${HIVE_CONF_DIR}/* ${HADOOP_CONF_DIR}
# supervisorctl restart hive-server2
#supervisorctl restart hive-metastore

# Configuration http://svn.apache.org/repos/asf/hbase/hbase.apache.org/trunk/0.94/book/zk.sasl.auth.html
cd ${RANGER_HBASE_HOME}
mkdir -p /var/log/hbase/audit/hdfs/spool
chown -R hbase:hadoop /var/log/hbase
./enable-hbase-plugin.sh >> /var/log/hadoop-ranger/hadoop-ranger-hbase-setup.log
ln -sfn ${HBASE_CONF_DIR}/* ${HADOOP_CONF_DIR}
mv ${HADOOP_CONF_DIR}/ranger-hbase-audit.xml ${HADOOP_CONF_DIR}/ranger-hbase-hbasedev-audit.xml
mv ${HADOOP_CONF_DIR}/ranger-hbase-security.xml ${HADOOP_CONF_DIR}/ranger-hbase-hbasedev-security.xml
cp ${HADOOP_CONF_DIR}/ranger-policymgr-ssl.xml ${HADOOP_CONF_DIR}/ranger-hbase-policymgr-ssl.xml
cp ${HADOOP_CONF_DIR}/ranger-hbase-policymgr-ssl.xml ${HADOOP_CONF_DIR}/ranger-hbase-hbasedev-policymgr-ssl.xml

# https://community.cloudera.com/t5/Support-Questions/HBase-Master-Failed-to-become-active-master/td-p/27186
# supervisorctl restart hbase-master
# supervisorctl restart hbase-regionserver
# hdfs dfs -rm -r /hbase/* >> /var/log/hadoop-hbase/hbase-master-rm.log &
# supervisorctl restart hbase-thrift
# supervisorctl restart hbase-rest

# http://localhost:16010/master-status
# http://localhost:16030/rs-status
# http://localhost:8085/rest.jsp
# http://localhost:9095/thrift.jsp/tmp/hadoop-yarn/nm-local-dir 

cd ${RANGER_SOLR_PUGIN_HOME}
mkdir -pv /var/log/solr/audit/solr/spool
chown -R solr:hadoop /var/log/solr
./enable-solr-plugin.sh >> /var/log/hadoop-solr/hadoop-ranger-solr-setup.log
ln -sfn /opt/solr/server/resources/* ${HADOOP_CONF_DIR}
# /opt/solr/ranger_audit_server/scripts/stop_solr.sh >> /var/log/hadoop-solr/solr-stop.log 
# /opt/solr/ranger_audit_server/scripts/start_solr.sh >> /var/log/hadoop-solr/solr-start.log 

cd ${RANGER_ATLAS_PUGIN_HOME}
mkdir -pv /var/log/atlas/audit/hdfs/spool
chown -R atlas:hadoop /var/log/atlas
./enable-atlas-plugin.sh >> /var/log/hadoop-ranger/hadoop-ranger-atlas-setup.log
# su atlas -c "/usr/local/atlas/bin/atlas_stop.py" >> /var/log/hadoop-ranger/hadoop-ranger-atlas-stop.log
ln -sfn ${ATLAS_CONF_DIR}/* ${HADOOP_CONF_DIR}
# supervisorctl restart atlas-server
