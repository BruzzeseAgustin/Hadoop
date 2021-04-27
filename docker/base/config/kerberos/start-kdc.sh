#! /bin/bash

export KDC_MASTER_PASSWORD=changeme
/usr/sbin/kdb5_util -P $KDC_MASTER_PASSWORD create -s


## password only user
/usr/sbin/kadmin.local -q "addprinc  -randkey ifilonenko"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/ifilonenko.keytab ifilonenko"

/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/server.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/server.keytab HTTP/server.example.com"

/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/localhost"
/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/localhost"
/usr/sbin/kadmin.local -q "addprinc -randkey hdfs/dn1.example.com"
/usr/sbin/kadmin.local -q "addprinc -randkey HTTP/dn1.example.com"

kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/localhost"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/localhost"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab hdfs/dn1.example.com"
/usr/sbin/kadmin.local -q "ktadd -k /var/keytabs/hdfs.keytab HTTP/dn1.example.com"

/usr/sbin/kadmin.local -q "ank -randkey hdfs/localhost" 
/usr/sbin/kadmin.local -q "ank -randkey yarn/localhost" 
/usr/sbin/kadmin.local -q "ank -randkey hive/localhost" 
/usr/sbin/kadmin.local -q "ank -randkey HTTP/localhost" 
mkdir -p /var/keytabs/ 
/usr/sbin/kadmin.local -q "xst -k /var/keytabs/hdfs.keytab hdfs/localhost HTTP/localhost" 
/usr/sbin/kadmin.local -q "xst -k /var/keytabs/yarn.keytab yarn/localhost HTTP/localhost" 
/usr/sbin/kadmin.local -q "xst -k /var/keytabs/hive.keytab hive/localhost" 
/usr/sbin/kadmin.local -q "xst -k /var/keytabs/HTTP.keytab HTTP/localhost" 
chown hdfs:hadoop /var/keytabs/hdfs.keytab 
chown yarn:hadoop /var/keytabs/yarn.keytab 
chown hdfs:hadoop /var/keytabs/HTTP.keytab 

chown hdfs /var/keytabs/hdfs.keytab


keytool -genkey -alias localhost -keyalg rsa -keysize 1024 -dname "CN=localhost" -keypass changeme -keystore /var/keytabs/hdfs.jks -storepass changeme
keytool -genkey -alias dn1.example.com -keyalg rsa -keysize 1024 -dname "CN=dn1.example.com" -keypass changeme -keystore /var/keytabs/hdfs.jks -storepass changeme

chmod 700 /var/keytabs/hdfs.jks
chown hdfs /var/keytabs/hdfs.jks


krb5kdc -n
