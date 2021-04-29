#!/bin/bash

sudo service ssh start

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

chown hdfs:hadoop ${KEYTAB_DIR}/hdfs.keytab
chown yarn:hadoop ${KEYTAB_DIR}/yarn.keytab
chown mapred:hadoop ${KEYTAB_DIR}/mapred.keytab
chown hdfs:hadoop ${KEYTAB_DIR}/HTTP.keytab 

klist -ket ${KEYTAB_DIR}/hdfs.keytab 
klist -ket ${KEYTAB_DIR}/yarn.keytab 
klist -ket ${KEYTAB_DIR}/mapred.keytab 
klist -ket ${KEYTAB_DIR}/HTTP.keytab

echo 'Y' | sudo -E -u hdfs $HADOOP_HOME/bin/hdfs namenode -format 

mkdir -p /tmp/hadoop-hdfs/dfs/

supervisord

sudo chmod -R 777 /usr/local/hadoop

# keep container running
tail -f /dev/null
