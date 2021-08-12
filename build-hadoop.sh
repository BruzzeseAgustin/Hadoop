#!/bin/bash

# Clean up results from previous tests, if exists


if [[ ! -e $(pwd)/docker/config/results/ ]]; then
    echo "Error: Directory $(pwd)/docker/config/results/ does not exists."
    mkdir -p $(pwd)/docker/config/results/
    echo "Succesful: Created directory $(pwd)/docker/config/results/ ."
elif [[ -d $(pwd)/docker/config/results/ ]]; then
    echo "Directory $(pwd)/docker/config/results/* exists." 
    echo "Cleaning up results from previous deploy"
    rm -f $(pwd)/docker/config/results/*
fi

if [[ ! -e $(pwd)/docker/config/keytabs/ ]]; then
    echo "Error: Directory $(pwd)/docker/config/keytab/ does not exists."
    mkdir -p $(pwd)/docker/config/keytabs/
    echo "Succesful: Created directory (pwd)/docker/config/keytabs/ ."
elif [[ -d $(pwd)/docker/config/keytabs/ ]]; then
    echo "Directory $(pwd)/docker/config/keytabs/* exists." 
    echo "Cleaning up keytabs from previous deploy"
    rm -f $(pwd)/docker/config/keytabs/*
fi

# Download tar.gz 
# VERSIONS
export HADOOP_VERSION=3.2.2
export TEZ_VERSION=0.10.0
export SPARK_VERSION=3.1.2
export ZKEPPER_VERSION=3.7.0
export HBASE_VERSION=2.4.5
export SOLR_HOME=5.2.1
export HIVE_VERSION=3.1.2 
export RANGER_VERSION=2.1
export ATLAS_VERSION=2.1.0

read -p "Do you want to download hadoop dependencies again? " -n 1 -r
echo    # (optional) move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]
then
	# delete previous downloaded tar.gz
	rm $(pwd)/zip/hadoop-*.tar.gz
	rm $(pwd)/zip/tez/apache-tez-*-bin.tar.gz
	rm $(pwd)/zip/tez/tez-ui-*.war
	rm $(pwd)/zip/spark-*-bin-hadoop3.2.tgz
	rm $(pwd)/zip/apache-zookeeper-*-bin.tar.gz
	rm $(pwd)/zip/hbase-*-bin.tar.gz
	rm -rf $(pwd)/zip/incubator-ranger

	# Create folder with containing hadoop dependencies
	if [ ! -d $(pwd)/docker/dependencies/hive ] || [ ! -d $(pwd)/docker/dependencies/atlas ] || [ ! -d $(pwd)/docker/dependencies/ranger ] || [ ! -d $(pwd)/docker/dependencies/tez ]; then
	  mkdir -p $(pwd)/docker/dependencies/hive;
	  mkdir -p $(pwd)/docker/dependencies/atlas;
	  mkdir -p $(pwd)/docker/dependencies/ranger;
	  mkdir -p $(pwd)/docker/dependencies/tez;
	fi

	# Get by URLS & Untar all tar services  
	wget -N https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -P $(pwd)/zip/ && tar -xzvf $(pwd)/zip/hadoop-${HADOOP_VERSION}.tar.gz -C $(pwd)/docker/dependencies/

	wget -N https://ftp.cixug.es/apache/zookeeper/zookeeper-${ZKEPPER_VERSION}/apache-zookeeper-${ZKEPPER_VERSION}-bin.tar.gz -P $(pwd)/zip/ && tar -xzvf $(pwd)/zip/apache-zookeeper-${ZKEPPER_VERSION}-bin.tar.gz -C $(pwd)/docker/dependencies/

	wget -N https://mirrors.estointernet.in/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz -P $(pwd)/zip/ && tar -xzvf $(pwd)/zip/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz -C $(pwd)/docker/dependencies/

	wget -N https://ftp.cixug.es/apache/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz -P $(pwd)/zip/ && tar -xzvf $(pwd)/zip/hbase-${HBASE_VERSION}-bin.tar.gz -C $(pwd)/docker/dependencies/

	wget -N http://archive.apache.org/dist/lucene/solr/${SOLR_HOME}/solr-${SOLR_HOME}.tgz -P $(pwd)/zip/ && tar -xzvf $(pwd)/zip/solr-${SOLR_HOME}.tgz -C $(pwd)/docker/dependencies/

	wget -N https://downloads.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz -P $(pwd)/zip/tez/ && tar -xzvf $(pwd)/zip/tez/apache-tez-${TEZ_VERSION}-bin.tar.gz -C $(pwd)/docker/dependencies/tez/

	wget -N https://repo1.maven.org/maven2/org/apache/tez/tez-ui/${TEZ_VERSION}/tez-ui-${TEZ_VERSION}.war -P $(pwd)/docker/dependencies/tez/

	git clone https://github.com/apache/incubator-ranger.git $(pwd)/docker/dependencies/incubator-ranger

	# This are exclusive tar services when you clone this project
	tar -xzvf $(pwd)/zip/hive/apache-hive-${HIVE_VERSION}-bin.tar.gz -C $(pwd)/docker/dependencies/hive/
	for f in $(pwd)/zip/ranger/*.tar.gz; do tar -xzvf "$f" -C $(pwd)/docker/dependencies/ranger/; done
	tar -xzvf $(pwd)/zip/atlas/apache-atlas-${ATLAS_VERSION}-server.tar.gz -C $(pwd)/docker/dependencies/atlas/

fi

## Configure Docker image with the versions specified
# create Dockefile image
# yes | cp -rf docker/Templatefile docker/Hadoopfile
# sed -i "s|HADOOP_VERSION=|HADOOP_VERSION=$HADOOP_VERSION|" docker/Hadoopfile
# sed -i "s|TEZ_VERSION=|TEZ_VERSION=$TEZ_VERSION|" docker/Hadoopfile
# sed -i "s|SPARK_VERSION=|SPARK_VERSION=$SPARK_VERSION|" docker/Hadoopfile
# sed -i "s|ZKEPPER_VERSION=|ZKEPPER_VERSION=$ZKEPPER_VERSION|" docker/Hadoopfile
# sed -i "s|HBASE_VERSION=|HBASE_VERSION=$HBASE_VERSION|" docker/Hadoopfile
# sed -i "s|SOLR_HOME=|SOLR_HOME=$SOLR_HOME|" docker/Hadoopfile
# sed -i "s|HIVE_VERSION=|HIVE_VERSION=$HIVE_VERSION|" docker/Hadoopfile
# sed -i "s|RANGER_VERSION=|RANGER_VERSION=$RANGER_VERSION|" docker/Hadoopfile
# sed -i "s|ATLAS_VERSION=|ATLAS_VERSION=$ATLAS_VERSION|" docker/Hadoopfile

## Build Docker image
read -p "Do you want to build interactive hadoop image? " -n 1 -r
echo    # (optional) move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]
then
	# create base hadoop cluster docker image
	docker build -f docker/Hadoopfile -t hadoop-hive-base:latest docker | while read line ; do echo "$(date)| $line" | tee -a $(pwd)/docker/config/results/docker-build.txt ; done; 

	echo "start hadoop-master container..."
	docker run -p 9864:9864 -p 9870:9870 -p 8088:8088 -p 19888:19888 -p 10020:10020 -p 8042:8042 -p 8188:8188 -p 9999:9999 -p 6080:6080 -p 6083:6083 -p 8080:8080 -p 464:464 -p 88:88 -p 749:749 -p 18080:18080 -p 2181:2181 -p 8030:8030 -p 60010:60010 -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 -p 8021:8021 -p 9095:9095 -p 8085:8085 -p 10002:10002 -p 10000:10000 -p 10001:10001 -p 21000:21000 -p 35615:35615 \
		-h localhost \
		--name hadoop-hive \
		-v $(pwd)/docker/config/results/:/opt/ranger/results/ \
		-v $(pwd)/docker/config/keytabs/:/var/keytabs/ \
		-d hadoop-hive-base:latest

	# chech image is running
	docker ps -a 

	# get into hadoop master container
	docker exec -it hadoop-hive bash

else 
	# create base hadoop cluster docker image
	docker build -f docker/Dockerfile -t hadoop-hive-test:latest docker | while read line ; do echo "$(date)| $line" | tee -a $(pwd)/docker/config/results/docker-build.txt ; done; 

	echo "start hadoop-master container..."
	docker run hadoop-hive-test -israt \
		-p 9864:9864 -p 9870:9870 -p 8088:8088 -p 19888:19888 -p 10020:10020 -p 8042:8042 -p 8188:8188 -p 9999:9999 -p 6080:6080 -p 6083:6083 -p 8080:8080 -p 464:464 -p 88:88 -p 749:749 -p 18080:18080 -p 2181:2181 -p 8030:8030 -p 60010:60010 -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 -p 8021:8021 -p 9095:9095 -p 8085:8085 -p 10002:10002 -p 10000:10000 -p 10001:10001 -p 21000:21000 -p 35615:35615 \
		-h localhost \
		--name hadoop-hive \
		-v $(pwd)/docker/config/results/:/opt/ranger/results/ \
		-v $(pwd)/docker/config/keytabs/:/var/keytabs/ \
		-d hadoop-hive-base:latest \
	| while read line ; do echo "$(date)| $line" | tee -a $(pwd)/docker/config/results/docker-run.txt ; done;

fi

# create a local ticker for testing
./init-krb.sh

