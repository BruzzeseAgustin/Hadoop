#!/bin/bash

sudo service ssh start

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
KDC_ADDRES=$(hostname -f)

# Create configuration file /etc/krb5.conf. The files installed by default contain several sample items.
cat>/etc/krb5.conf<<EOF
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = ${KRB_REALM}
 dns_lookup_kdc = false
 dns_lookup_realm = false
 ticket_lifetime = 24h
 # renew_lifetime = 7d 
 pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
 forwardable = true
 rdns = false

[realms]
 ${KRB_REALM} = {
    kdc = ${KDC_ADDRES}
    admin_server = ${KDC_ADDRES}
 }

[domain_realm]
  .${KDC_ADDRES} = ${KRB_REALM}
  ${KDC_ADDRES} = ${KRB_REALM}

[kdc]
  profile=/var/kerberos/krb5kdc/kdc.conf
EOF

# Create ACL (Access Control List) allows you to specify privileges precisely.
echo "*/admin@${KRB_REALM} *" > /var/kerberos/krb5kdc/kadm5.acl

# Create a database
kdb5_util -P ${KERB_MASTER_KEY} create -s 
chkconfig --level 35 krb5kdc on 
chkconfig --level 35 kadmin on 

# Create admin user, it should match with the ACL user
kadmin.local -q "addprinc -pw ${KERBEROS_ADMIN_PASSWORD} ${KERB_PRINCIPAL_USER}"

# create namenode kerberos principal and keytab
kadmin.local -q "addprinc -randkey hdfs/${KDC_ADDRES}" 
kadmin.local -q "addprinc -randkey yarn/${KDC_ADDRES}" 
kadmin.local -q "addprinc -randkey mapred/${KDC_ADDRES}" 
kadmin.local -q "addprinc -randkey HTTP/${KDC_ADDRES}" 
kadmin.local -q "addprinc -pw ${KERBEROS_ADMIN_PASSWORD} abruzzese/${KDC_ADDRES}"

# Create a keytab file
kadmin.local -q "xst -k ${KEYTAB_DIR}/hdfs.keytab hdfs/${KDC_ADDRES} HTTP/${KDC_ADDRES}"  
kadmin.local -q "xst -k ${KEYTAB_DIR}/yarn.keytab yarn/${KDC_ADDRES} HTTP/${KDC_ADDRES}"  
kadmin.local -q "xst -k ${KEYTAB_DIR}/mapred.keytab mapred/${KDC_ADDRES} HTTP/${KDC_ADDRES}" 
kadmin.local -q "xst -k ${KEYTAB_DIR}/abruzzese.keytab abruzzese/${KDC_ADDRES} HTTP/${KDC_ADDRES}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/HTTP.keytab HTTP/${KDC_ADDRES}" 

chown hdfs:hadoop ${KEYTAB_DIR}/hdfs.keytab 
chown yarn:hadoop ${KEYTAB_DIR}/yarn.keytab 
chown mapred:hadoop ${KEYTAB_DIR}/mapred.keytab 
chown hdfs:hadoop ${KEYTAB_DIR}/HTTP.keytab  
chown abruzzese:hadoop ${KEYTAB_DIR}/abruzzese.keytab

chgrp -R hadoop ${KEYTAB_DIR}/*.keytab 
chmod 640 ${KEYTAB_DIR}/*.keytab

# Verification of creation of keytab  
kadmin.local -q "listprincs" 
klist -ket ${KEYTAB_DIR}/hdfs.keytab 
klist -ket ${KEYTAB_DIR}/yarn.keytab 
klist -ket ${KEYTAB_DIR}/mapred.keytab 
klist -ket ${KEYTAB_DIR}/HTTP.keytab
klist -ket ${KEYTAB_DIR}/abruzzese.keytab

# Start the service
chkconfig krb5kdc on
chkconfig kadmin on
krb5kdc 
kadmind 

# At this point, the configuration is complete, and each component needs to be started
kinit -kt ${KEYTAB_DIR}/yarn.keytab yarn/$(hostname -f)  
kinit -kt ${KEYTAB_DIR}/mapred.keytab mapred/$(hostname -f)  
kinit -kt ${KEYTAB_DIR}/HTTP.keytab HTTP/$(hostname -f)

# The most important user-ticker for start is hdfs user
kinit -kt ${KEYTAB_DIR}/hdfs.keytab hdfs/$(hostname -f)
kinit -kt ${KEYTAB_DIR}/abruzzese.keytab abruzzese/$(hostname -f)

# Because of some permissions checks, the container-executor binary needs to be in a path owned by root. As root, do the following:
sudo chmod 6050 $HADOOP_HOME/bin/container-executor 
sudo chmod 755 /usr/local/hadoop
sudo chmod 755 /usr/local/hadoop/etc/  
sudo chown root /usr/local/hadoop/etc/hadoop
sudo chmod 755 /usr/local/hadoop/etc/hadoop 
sudo chmod 755 -R /usr/local/hadoop/etc/hadoop
sudo chmod 755 /usr/local/hadoop/etc/hadoop/*

echo 'Y' | sudo -E -u hdfs $HADOOP_HOME/bin/hdfs namenode -format 

# Start HDFS, YARM, and MAPREDUCE daemons
supervisord

# keep container running
tail -f /dev/null
