#!/bin/bash

sudo service ssh start


$HADOOP_HOME/etc/hadoop/hadoop-env.sh
KDC_ADDRES=$(hostname -f)

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

echo "*/admin@${KRB_REALM} *" > /var/kerberos/krb5kdc/kadm5.acl
kdb5_util -P "${KERBEROS_ADMIN_PASSWORD}" create -s 
chkconfig --level 35 krb5kdc on 
chkconfig --level 35 kadmin on 
kadmin.local -q "addprinc -randkey hdfs/${KDC_ADDRES}" 
kadmin.local -q "addprinc -randkey yarn/${KDC_ADDRES}" 
kadmin.local -q "addprinc -randkey mapred/${KDC_ADDRES}" 
kadmin.local -q "addprinc -randkey HTTP/${KDC_ADDRES}" 
kadmin.local -q "xst -k  hdfs/${KDC_ADDRES} HTTP/${KDC_ADDRES}"  
kadmin.local -q "xst -k ${KEYTAB_DIR}/yarn.keytab yarn/${KDC_ADDRES} HTTP/${KDC_ADDRES}"  
kadmin.local -q "xst -k ${KEYTAB_DIR}/mapred.keytab mapred/${KDC_ADDRES} HTTP/${KDC_ADDRES}" 
kadmin.local -q "xst -k ${KEYTAB_DIR}/HTTP.keytab HTTP/${KDC_ADDRES}" 
kadmin.local -q "ktadd -k ${KEYTAB_DIR}/hdfs.keytab hdfs/${KDC_ADDRES} HTTP/${KDC_ADDRES}"  
kadmin.local -q "ktadd -k ${KEYTAB_DIR}/yarn.keytab yarn/${KDC_ADDRES} HTTP/${KDC_ADDRES}" 
kadmin.local -q "ktadd -k ${KEYTAB_DIR}/mapred.keytab mapred/${KDC_ADDRES} HTTP/${KDC_ADDRES}" 
kadmin.local -q "ktadd -k ${KEYTAB_DIR}/HTTP.keytab HTTP/${KDC_ADDRES}" 
chown hdfs:hadoop ${KEYTAB_DIR}/hdfs.keytab 
chown yarn:hadoop ${KEYTAB_DIR}/yarn.keytab 
chown mapred:hadoop ${KEYTAB_DIR}/mapred.keytab 
chown hdfs:hadoop ${KEYTAB_DIR}/HTTP.keytab  
chgrp -R hadoop ${KEYTAB_DIR}/*.keytab 
chmod 640 ${KEYTAB_DIR}/*.keytab  
kadmin.local -q "listprincs" 
klist -ket ${KEYTAB_DIR}/hdfs.keytab 
klist -ket ${KEYTAB_DIR}/yarn.keytab 
klist -ket ${KEYTAB_DIR}/mapred.keytab 
klist -ket ${KEYTAB_DIR}/HTTP.keytab

echo 'Y' | sudo -E -u hdfs $HADOOP_HOME/bin/hdfs namenode -format 

mkdir -p /tmp/hadoop-hdfs/dfs/

supervisord

# At this point, the configuration is complete, and each component needs to be started
kinit -kt ${KEYTAB_DIR}/hdfs.keytab hdfs/${KDC_ADDRES} 
kinit -kt ${KEYTAB_DIR}/yarn.keytab yarn/${KDC_ADDRES}  
kinit -kt ${KEYTAB_DIR}/mapred.keytab mapred/${KDC_ADDRES}  
kinit -kt ${KEYTAB_DIR}/HTTP.keytab HTTP/${KDC_ADDRES}


sudo chmod -R 777 /usr/local/hadoop

# keep container running
tail -f /dev/null
