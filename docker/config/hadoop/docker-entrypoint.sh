#!/bin/bash

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
KDC_ADDRES=$(hostname -f)

## Run Kerberos initialization
/opt/tools/run_tests_docker.sh -i

## Start SOLR
/opt/tools/run_tests_docker.sh -s

## Start Ranger
/opt/tools/run_tests_docker.sh -r

## Start Hadoop
/opt/tools/run_tests_docker.sh -a

## Run Hadoop Application and Web tests
/opt/tools/run_tests_docker.sh -t

tail -f /dev/null

