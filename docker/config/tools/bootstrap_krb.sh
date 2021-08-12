#!/bin/bash

# $HADOOP_HOME/etc/hadoop/hadoop-env.sh
KDC_ADDRES=$(hostname -f)
DOCKER_FIRSTRUN=/var/kerberos/.docker_firstrun 

retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1

    until $cmd
    do
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            exit
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $(( attempt_num++ ))
        fi
    done
}

function defaults {
    : ${KRB_REALM:=EXAMPLE.COM}
    : ${KRB5REALM:=EXAMPLE.COM}
    : ${DOMAIN_REALM:=example.com}
    : ${KERB_MASTER_KEY:=masterkey}
    : ${KERB_ADMIN_USER:=admin}
    : ${KERB_ADMIN_PASS:=admin}
    : ${KDC_ADDRES:=$(hostname -f)}
    : ${KERB_PRINCIPAL_USER:=root/admin}
    : ${DOCKER_FIRSTRUN:=/var/kerberos/.docker_firstrun}

    export KRB5REALM
}

function create_admin_user() {
    echo "Creating admin user"
    kadmin.local -q "addprinc -pw ${KERB_ADMIN_PASS} ${KERB_PRINCIPAL_USER}"
    echo "*/admin@${KRB_REALM} *" > /var/kerberos/krb5kdc/kadm5.acl
    echo admin | kinit ${KERB_PRINCIPAL_USER}
    klist 2>&1 | tee /opt/ranger/results/test-admin-00_output.txt
}


function create_db() {
    echo "Creating db"
    /usr/sbin/kdb5_util -P ${KERB_MASTER_KEY} -r ${KRB_REALM} create -s
    chkconfig --level 35 krb5kdc on 
    chkconfig --level 35 kadmin on 
}


# Create configuration file /etc/krb5.conf. The files installed by default contain several sample items.
function create_config() {
    echo "Creating config"
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
    kdc = ${KDC_ADDRES}:88
    admin_server = ${KDC_ADDRES}:749
    default_domain = ${KDC_ADDRES}
 }
[domain_realm]
  .${KDC_ADDRES} = ${KRB_REALM}
  ${KDC_ADDRES} = ${KRB_REALM}
[kdc]
  profile=/var/kerberos/krb5kdc/kdc.conf
EOF
}

function firstrun {
    if ! [[ -f ${DOCKER_FIRSTRUN} ]]; then
        create_config
        create_db
        create_admin_user
        touch ${DOCKER_FIRSTRUN}
    fi
}

defaults
firstrun

echo admin | kinit ${KERB_PRINCIPAL_USER} &>>/var/log/krb-admin.log
# create namenode kerberos principal and keytab
kadmin.local -q "addprinc -randkey hdfs/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey yarn/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey mapred/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey hive/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey spark/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey zookeeper/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey hbase/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey atlas/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey ranger/$(hostname -f)" &>>/var/log/krb-usrs.log  
kadmin.local -q "addprinc -randkey rangeradmin/$(hostname -f)" &>>/var/log/krb-usrs.log  
kadmin.local -q "addprinc -randkey rangerusersync/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey rangerlookup/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey rangerlogger/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey rangertagsync/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey tallada" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey jcarrete" &>>/var/log/krb-usrs.log
kadmin.local -q "addprinc -randkey abruzzese" &>>/var/log/krb-usrs.log

# Create kerberos test user 
kadmin.local -q "addprinc -pw test user"

# Create a keytab file
kadmin.local -q "xst -k ${KEYTAB_DIR}/hdfs.keytab hdfs/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log  
kadmin.local -q "xst -k ${KEYTAB_DIR}/yarn.keytab yarn/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log 
kadmin.local -q "xst -k ${KEYTAB_DIR}/mapred.keytab mapred/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive.keytab hive/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/spark.keytab spark/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/zookeeper.keytab zookeeper/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/hbase.keytab hbase/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/atlas.keytab atlas/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/ranger.keytab ranger/$(hostname -f) rangeradmin/$(hostname -f)  rangerlookup/$(hostname -f) rangertagsync/$(hostname -f) ktadd -norandkey -k ranger_http.keytab HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log 
kadmin.local -q "xst -k ${KEYTAB_DIR}/rangerusersync.keytab rangerusersync/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/rangerlookup.keytab rangerlookup/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/rangerlogger.keytab rangerlogger/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/rangertagsync.keytab rangertagsync/$(hostname -f) HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/tallada.keytab tallada HTTP" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/jcarrete.keytab jcarrete HTTP" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/abruzzese.keytab abruzzese HTTP" &>>/var/log/krb-usrs.log
kadmin.local -q "xst -k ${KEYTAB_DIR}/HTTP.keytab HTTP/$(hostname -f)" &>>/var/log/krb-usrs.log

chown hdfs:hadoop ${KEYTAB_DIR}/hdfs.keytab 
chown yarn:hadoop ${KEYTAB_DIR}/yarn.keytab 
chown mapred:hadoop ${KEYTAB_DIR}/mapred.keytab 
chown hdfs:hadoop ${KEYTAB_DIR}/HTTP.keytab
chown hive:hadoop ${KEYTAB_DIR}/hive.keytab  
chown spark:hadoop ${KEYTAB_DIR}/spark.keytab 
chown hbase:hadoop ${KEYTAB_DIR}/hbase.keytab 
chown atlas:hadoop ${KEYTAB_DIR}/atlas.keytab
chown zookeeper:hadoop ${KEYTAB_DIR}/zookeeper.keytab 
chown ranger:hadoop ${KEYTAB_DIR}/ranger.keytab
chown rangerlookup:hadoop ${KEYTAB_DIR}/ranger.keytab
chown tallada:hadoop ${KEYTAB_DIR}/tallada.keytab
chown jcarrete:hadoop ${KEYTAB_DIR}/jcarrete.keytab
chown abruzzese:hadoop ${KEYTAB_DIR}/abruzzese.keytab

chgrp -R hadoop ${KEYTAB_DIR}/*.keytab 
chmod 644 ${KEYTAB_DIR}/*.keytab
chmod 755 ${KEYTAB_DIR}/yarn.keytab
chmod 755 ${KEYTAB_DIR}/HTTP.keytab

supervisorctl start krb5kdc 
supervisorctl start kadmind 

kinit -kt ${KEYTAB_DIR}/abruzzese.keytab abruzzese@${KRB_REALM} 
echo "========== Verifying Kerberos... =========="
klist -ket ${KEYTAB_DIR}/abruzzese.keytab 2>&1 | tee /opt/ranger/results/test-admin-01_output.txt
ret_code=$?
if [ $ret_code != 0 ]; then
  echo "Error : Wrong bad inicialization ofthe kerberos service"
  exit $ret_code
fi

