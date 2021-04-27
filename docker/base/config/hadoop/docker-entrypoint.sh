#!/bin/bash

sudo service ssh start

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

echo 'Y' | sudo -E -u hdfs $HADOOP_HOME/bin/hdfs namenode -format 

mkdir -p /tmp/hadoop-hdfs/dfs/

supervisord

sudo chmod -R 777 /usr/local/hadoop

# keep container running
tail -f /dev/null
