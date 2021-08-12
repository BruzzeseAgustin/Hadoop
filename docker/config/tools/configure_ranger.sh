#!/bin/bash

#---------------------------------------
#
#       Configure Ranger Services
#
#---------------------------------------

function configure() {

  local path=$1
  local name=$2
  local value=$3
  
  local var
  local value

  if ! grep -qF "$name" $path; then
     echo "Property $name does not exists"
     echo "Adding $name with value $value"
     echo "$name=$value" >> $path 
  else 
     echo "Configuring $name with value $value"
     sed -i "s|$name=|$name=$value|" $path
  fi

}

# #---------------------------------------
# #       Configure ADMIN Service
# #---------------------------------------

configure ${RANGER_HOME}/install.properties JAVA_HOME $(dirname $(dirname $(readlink $(readlink $(which javac)))))
# #---------------------------------------
# #       Configure HDFS Service
# #---------------------------------------

configure ${RANGER_HDFS_HOME}/install.properties POLICY_MGR_URL http://localhost:6080
configure ${RANGER_HDFS_HOME}/install.properties REPOSITORY_NAME hadoopdev
configure ${RANGER_HDFS_HOME}/install.properties COMPONENT_INSTALL_DIR_NAME ${HADOOP_HOME}
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.SOLR.FILE_SPOOL_DIR /opt/solr/ranger_audit_server/
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.HDFS.DESTINATION_DIRECTORY hdfs://localhost:9000/ranger/audit/%app-type%/%time:yyyyMMdd%
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.HDFS.FILE_SPOOL_DIR /var/log/hadoop/hdfs/audit/hdfs/spool
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY /var/log/hadoop/%app-type%/audit
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY /var/log/hadoop/%app-type%/audit/archive
configure ${RANGER_HDFS_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_HDFS_HOME}/install.properties SSL_KEYSTORE_FILE_PATH /etc/hadoop/conf/ranger-plugin-keystore.jks
configure ${RANGER_HDFS_HOME}/install.properties SSL_KEYSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_HDFS_HOME}/install.properties SSL_TRUSTSTORE_FILE_PATH /etc/hadoop/conf/ranger-plugin-truststore.jks
configure ${RANGER_HDFS_HOME}/install.properties SSL_TRUSTSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_HDFS_HOME}/install.properties CUSTOM_USER hdfs
configure ${RANGER_HDFS_HOME}/install.properties CUSTOM_GROUP hadoop

# #---------------------------------------
# #       Configure YARN Service
# #---------------------------------------

configure ${RANGER_YARN_HOME}/install.properties POLICY_MGR_URL http://localhost:6080
configure ${RANGER_YARN_HOME}/install.properties REPOSITORY_NAME yarndev
configure ${RANGER_YARN_HOME}/install.properties COMPONENT_INSTALL_DIR_NAME ${HADOOP_HOME}
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.SOLR.FILE_SPOOL_DIR /opt/solr/ranger_audit_server/
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.HDFS.DESTINATION_DIRECTORY hdfs://localhost:9000/ranger/audit/%app-type%/%time:yyyyMMdd%
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.HDFS.FILE_SPOOL_DIR /var/log/hadoop/yarn/audit/hdfs/spool
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY /var/log/yarn/audit/archive
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY /var/log/yarn/audit/archive
configure ${RANGER_YARN_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_YARN_HOME}/install.properties SSL_KEYSTORE_FILE_PATH /etc/hadoop/conf/ranger-plugin-keystore.jks
configure ${RANGER_YARN_HOME}/install.properties SSL_KEYSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_YARN_HOME}/install.properties SSL_TRUSTSTORE_FILE_PATH /etc/hadoop/conf/ranger-plugin-truststore.jks
configure ${RANGER_YARN_HOME}/install.properties SSL_TRUSTSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_YARN_HOME}/install.properties CUSTOM_USER yarn
configure ${RANGER_YARN_HOME}/install.properties CUSTOM_GROUP hadoop

# #---------------------------------------
# #       Configure HIVE Service
# #---------------------------------------

configure ${RANGER_HIVE_HOME}/install.properties POLICY_MGR_URL http://localhost:6080
configure ${RANGER_HIVE_HOME}/install.properties REPOSITORY_NAME hivedev
configure ${RANGER_HIVE_HOME}/install.properties COMPONENT_INSTALL_DIR_NAME ${HIVE_HOME}
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.SOLR.FILE_SPOOL_DIR /opt/solr/ranger_audit_server
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.HDFS.DESTINATION_DIRECTORY hdfs://localhost:9000/ranger/audit/%app-type%/%time:yyyyMMdd%
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.HDFS.FILE_SPOOL_DIR /var/log/hive/audit/hdfs/spool
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY /var/log/hive/audit
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY /var/log/hive/audit/archive
configure ${RANGER_HIVE_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_HIVE_HOME}/install.properties SSL_KEYSTORE_FILE_PATH /etc/hive/conf/ranger-plugin-keystore.jks
configure ${RANGER_HIVE_HOME}/install.properties SSL_KEYSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_HIVE_HOME}/install.properties SSL_TRUSTSTORE_FILE_PATH /etc/hive/conf/ranger-plugin-truststore.jks
configure ${RANGER_HIVE_HOME}/install.properties SSL_TRUSTSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_HIVE_HOME}/install.properties UPDATE_XAPOLICIES_ON_GRANT_REVOKE true
configure ${RANGER_HIVE_HOME}/install.properties CUSTOM_USER hive
configure ${RANGER_HIVE_HOME}/install.properties CUSTOM_GROUP hadoop

# #---------------------------------------
# #       Configure SOLR Service
# #---------------------------------------

configure ${RANGER_SOLR_PUGIN_HOME}/install.properties POLICY_MGR_URL http://localhost:6080
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties REPOSITORY_NAME solrdev
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties COMPONENT_INSTALL_DIR_NAME ${SOLR_HOME}/server
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.SOLR.FILE_SPOOL_DIR /opt/solr/ranger_audit_server/
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.HDFS.DESTINATION_DIRECTORY hdfs://localhost:9000/ranger/audit/%app-type%/%time:yyyyMMdd%
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.HDFS.FILE_SPOOL_DIR /opt/solr/ranger_audit_server/
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY /var/log/solr/audit
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY /var/log/solr/audit/archive/
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties SSL_KEYSTORE_FILE_PATH =/etc/hadoop/conf/ranger-plugin-keystore.jks
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties SSL_KEYSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties SSL_TRUSTSTORE_FILE_PATH =/etc/hadoop/conf/ranger-plugin-truststore.jks
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties SSL_TRUSTSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties CUSTOM_USER solr
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties CUSTOM_GROUP hadoop
configure ${RANGER_SOLR_PUGIN_HOME}/install.properties XAAUDIT.SUMMARY.ENABLE true

# #---------------------------------------
# #       Configure HBASE Service
# #---------------------------------------

configure ${RANGER_HBASE_HOME}/install.properties POLICY_MGR_URL http://localhost:6080
configure ${RANGER_HBASE_HOME}/install.properties REPOSITORY_NAME hbasedev
configure ${RANGER_HBASE_HOME}/install.properties COMPONENT_INSTALL_DIR_NAME ${HBASE_HOME}
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.SOLR.FILE_SPOOL_DIR /opt/solr/ranger_audit_server/
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.HDFS.DESTINATION_DIRECTORY hdfs://localhost:9000/ranger/audit/%app-type%/%time:yyyyMMdd%
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.HDFS.FILE_SPOOL_DIR /var/log/hbase/audit/hdfs/spool
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY /var/log/hbase/audit/%app-type%
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY /var/log/hbase/audit/archive/%app-type%
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_HBASE_HOME}/install.properties SSL_KEYSTORE_FILE_PATH /etc/hbase/conf/ranger-plugin-keystore.jks
configure ${RANGER_HBASE_HOME}/install.properties SSL_KEYSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_HBASE_HOME}/install.properties SSL_TRUSTSTORE_FILE_PATH /etc/hbase/conf/ranger-plugin-truststore.jks
configure ${RANGER_HBASE_HOME}/install.properties SSL_TRUSTSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_HBASE_HOME}/install.properties UPDATE_XAPOLICIES_ON_GRANT_REVOKE true
configure ${RANGER_HBASE_HOME}/install.properties CUSTOM_USER hbase
configure ${RANGER_HBASE_HOME}/install.properties CUSTOM_GROUP hadoop
configure ${RANGER_HBASE_HOME}/install.properties XAAUDIT.SUMMARY.ENABLE true
# #---------------------------------------
# #       Configure ATLAS Service
# #---------------------------------------

configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties POLICY_MGR_URL http://localhost:6080
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties REPOSITORY_NAME atlasdev
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties COMPONENT_INSTALL_DIR_NAME ${ATLAS_HOME}
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.SOLR.FILE_SPOOL_DIR /opt/solr/ranger_audit_server/
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.HDFS.DESTINATION_DIRECTORY hdfs://localhost:9000/ranger/audit/%app-type%/%time:yyyyMMdd%
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.HDFS.FILE_SPOOL_DIR /var/log/atlas/audit/hdfs/spool
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.HDFS.LOCAL_BUFFER_DIRECTORY /var/log/atlas/audit/%app-type%
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.HDFS.LOCAL_ARCHIVE_DIRECTORY /var/log/atlas/audit/archive/%app-type%
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.SOLR.SOLR_URL http://localhost:6083/solr/ranger_audits
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties SSL_KEYSTORE_FILE_PATH /etc/atlas/conf/ranger-plugin-keystore.jks
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties SSL_KEYSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties SSL_TRUSTSTORE_FILE_PATH /etc/atlas/conf/ranger-plugin-truststore.jks
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties SSL_TRUSTSTORE_PASSWORD s3cUr1tyr4Ng3r
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties CUSTOM_USER atlas
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties CUSTOM_GROUP hadoop
configure ${RANGER_ATLAS_PUGIN_HOME}/install.properties XAAUDIT.SUMMARY.ENABLE true

#---------------------------------------
#       Start Services
#---------------------------------------
PATH=$PATH:$RANGER_ADMIN_HOME
