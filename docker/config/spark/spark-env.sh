#!/usr/bin/env bash

export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/
export HIVE_HOME=/opt/hive
export SPARK_HOME=/usr/local/spark
export SPARK_CONF_DIR=${SPARK_HOME}/conf
export SPARK_LOG_DIR=${SPARK_HOME}/logs
export SPARK_DIST_CLASSPATH=/usr/local/hadoop/etc/hadoop/:/usr/local/hadoop/share/hadoop/common/lib/*:/usr/local/hadoop/share/hadoop/common/*:/usr/local/hadoop/share/hadoop/hdfs:/usr/local/hadoop/share/hadoop/hdfs/lib/*:/usr/local/hadoop/share/hadoop/hdfs/*:/usr/local/hadoop/share/hadoop/yarn:/usr/local/hadoop/share/hadoop/yarn/lib/*:/usr/local/hadoop/share/hadoop/yarn/*:/usr/local/hadoop/share/hadoop/mapreduce/lib/*:/usr/local/hadoop/share/hadoop/mapreduce/*
export YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop/
