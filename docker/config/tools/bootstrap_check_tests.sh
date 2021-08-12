#!/bin/bash

# Ranger Services
python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-service-01_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-service-02_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-service-03_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-service-04_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-service-05_output.txt "id" -o /opt/ranger/results/data.txt

# Ranger Policies
python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-01_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-02_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-03_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-04_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-05_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-06_output.txt "id" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-policy-07_output.txt "id" -o /opt/ranger/results/data.txt

## Hadoop tests (hadoop, tez, and spark)
# Admin

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-00_output.txt "root/admin@EXAMPLE.COM" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-01_output.txt "abruzzese@EXAMPLE.COM" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-02_output.txt "Estimated value of Pi is 3.14800000000000000000" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-03_output.txt "The url to track the Tez AM" -o /opt/ranger/results/data.txt





python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-06_output.txt "bar	2" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-07_output.txt "final status: SUCCEEDED" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-08_output.txt "final status: SUCCEEDED" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-admin-09_output.txt "HiveAccessControlException Permission denied" -o /opt/ranger/results/data.txt

# Non-admin
python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-00_output.txt "tallada@EXAMPLE.COM" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-01_output.txt "Permission denied:" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-04_output.txt "Estimated value of Pi is 3.14800000000000000000" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-05_output.txt "The url to track the Tez AM" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-06_output.txt "bar	2" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-07_output.txt "final status: SUCCEEDED" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-08_output.txt "final status: SUCCEEDED" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-09_output.txt "INFO  : OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-10_output.txt "Permission denied: user [tallada]" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-13_output.txt "Permission denied: user [tallada]" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-14_output.txt "INFO  : OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-16_output.txt "Permission denied: user [tallada]" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-17_output.txt "Permission denied: user [tallada]" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-18_output.txt "INFO  : OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-19_output.txt "INFO  : OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-20_output.txt "INFO  : OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-21_output.txt "Permission denied: user [tallada]" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-non_admin-22_output.txt "INFO  : OK" -o /opt/ranger/results/data.txt


# Web managers 

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-tez-ui.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-hbase-rest.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-hbase-master.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-hbase-thrift.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-yarn-timeserver.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-node-loadingpage.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-resource-manager.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-solr-loadingpage.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-hbase-regionserver.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-ranger-loadingpage.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

python /opt/tools/hadoop-check-tests.py check_existance /opt/ranger/results/test-web-nodemanager-loadingpage.txt "HTTP/1.1 200 OK" -o /opt/ranger/results/data.txt

