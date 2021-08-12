#!/bin/bash


## Run Web tests

curl -is --negotiate -u : http://localhost:8088/cluster | tee /opt/ranger/results/test-web-resource-manager.txt


curl -is --negotiate -u : http://localhost:8042/node | tee /opt/ranger/results/test-web-node-loadingpage.txt
curl -is --negotiate -u : http://localhost:8188/applicationhistory 2>&1 | tee /opt/ranger/results/test-web-yarn-timeserver.txt
curl -is --negotiate -u : http://localhost:9870/dfshealth.html#tab-overview | tee /opt/ranger/results/test-web-nodemanager-loadingpage.txt

curl -is --negotiate -u : http://localhost:8080 | tee /opt/ranger/results/test-web-tez-ui.txt

curl -is --negotiate -u : http://localhost:6080 | tee /opt/ranger/results/test-web-ranger-loadingpage.txt
curl -is --negotiate -u : http://localhost:6083/solr/#/ | tee /opt/ranger/results/test-web-solr-loadingpage.txt

curl -is --negotiate -u : http://localhost:16010/master-status 2>&1 | tee /opt/ranger/results/test-web-hbase-master.txt
curl -is --negotiate -u : http://localhost:16030/rs-status 2>&1 | tee /opt/ranger/results/test-web-hbase-regionserver.txt
curl -is --negotiate -u : http://localhost:8085/rest.jsp 2>&1 | tee /opt/ranger/results/test-web-hbase-rest.txt
curl -is --negotiate -u : http://localhost:9095/thrift.jsp 2>&1 | tee /opt/ranger/results/test-web-hbase-thrift.txt
