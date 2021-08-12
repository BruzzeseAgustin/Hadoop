
build_docker_image:
	wget https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -P ./docker/base/zip/
	wget https://downloads.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz -P ./docker/base/zip/tez
	wget https://repo1.maven.org/maven2/org/apache/tez/tez-ui/${TEZ_VERSION}/tez-ui-${TEZ_VERSION}.war -P ./docker/base/zip/tez
	wget https://www.apache.org/dyn/closer.lua/zookeeper/zookeeper-${ZKEPPER_VERSION}/apache-zookeeper-${ZKEPPER_VERSION}-bin.tar.gz -P ./docker/base/zip/
	wget https://mirrors.estointernet.in/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz -P ./docker/base/zip/
	wget https://ftp.cixug.es/apache/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz -P ./docker/base/zip/
	wget https://ftp.cixug.es/apache/atlas/${ATLAS_VERSION}.0/apache-atlas-${ATLAS_VERSION}.0-sources.tar.gz -P ./docker/base/zip/
	wget http://archive.apache.org/dist/lucene/solr/${SOLR_HOME}/solr-${SOLR_HOME}.tgz -P ./docker/base/zip/
	git clone https://github.com/apache/incubator-ranger.git ./docker/base/zip/incubator-ranger
	awk '{sub("tail -f /dev/null","exit")}1' ./docker/base/config/hadoop/docker-entrypoint.sh > ./docker/base/config/hadoop/test.txt && mv ./docker/base/config/hadoop/test.txt ./docker/base/config/hadoop/docker-entrypoint.sh

image:
	docker build -t $(IMAGE) .

push-image:
	export IMAGE_NAME=$(docker ps --format "{{.Image}}" | head -1)
	docker tag $(IMAGE_NAME) $(IMAGE)/$(REPO_NAME):$(TRAVIS_BRANCH)
	docker push $(IMAGE)/$(REPO_NAME):$(TRAVIS_BRANCH)

.PHONY: 
	image push-image test

