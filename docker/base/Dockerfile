FROM centos:7

USER root

RUN yum -y install epel-release \
        curl \
	ssh \
	sudo \ 
        python \
        python-dev \
 	python-pip \
	python-setuptools \
        rsync \
        software-properties-common \
        unzip \
	openssh-server \
	less \
	java-1.8.0-openjdk-headless \
	wget \
	nano \
        && \
    yum clean all && \
    rm -rf /var/cache/yum/*
RUN yum -y install python-pip 

RUN pip install -U supervisor 
# Establecemos las variables de entorno JAVA_HOME apuntando a la ruta del JDK, HADOOP_HOME apuntando a 
# la ruta en la que hemos copiado Hadoop e incluimos en la variable PATH las rutas con los binarios y # scripts para gestionar Hadoop.

# Establecer JAVA
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk 

#####################################################################

# Descargar Hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_VERSION 3.2.2
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

# RUN set -x \
#     && wget -q "$HADOOP_URL" -O /tmp/hadoop.tar.gz \
#     && tar -xzf /tmp/hadoop.tar.gz -C /tmp/ \
#     && mv /tmp/hadoop-$HADOOP_VERSION $HADOOP_HOME \
#     && echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_CONF_DIR/hadoop-env.sh \
#     && echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

COPY zip/hadoop.tar.gz /tmp/hadoop.tar.gz
RUN tar -xzf /tmp/hadoop.tar.gz -C /tmp/ \
    && mv /tmp/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_CONF_DIR/hadoop-env.sh \
    && echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# Copiamos los ficheros de configuración y scripts que tenemos en el directorio config al directorio de hadoop
# Más adelante debería explicar cada fichero y su contenido...

COPY config/hadoop/core-site.xml $HADOOP_CONF_DIR/core-site.xml
COPY config/hadoop/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
COPY config/hadoop/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml
COPY config/hadoop/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
COPY config/hadoop/docker-entrypoint.sh $HADOOP_CONF_DIR/docker-entrypoint.sh

# La ejecución de Hadoop en modo pseudo-distribuido requiere ssh. 
# Añade lo siguiente a ~/.ssh/config para evitar tener que confirmar manualmente la conexión
# Creamos las claves ssh necesarias para que se comunique el NameNode con los demas componentes.
# Al tener todos las mismas claves e incluirlas como claves autorizadas, el acceso ssh entre los distintos nodos está garantizado.

COPY config/hadoop/ssh_config /etc/ssh/ssh_config

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

#####################################################################

# Descargar Spark
ENV SPARK_HOME /usr/local/spark
ENV SPARK_VERSION 3.1.1
ENV SPARK_URL https://mirrors.estointernet.in/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz

# RUN wget -q "$SPARK_URL" -O /tmp/spark.tgz && \
# 	tar -xvf /tmp/spark.tgz -C /tmp/ && \
#	mv -v /tmp/spark-$SPARK_VERSION-bin-without-hadoop $SPARK_HOME

#COPY zip/spark.tgz /tmp/spark.tgz 
# RUN tar -xvf /tmp/spark.tgz -C /tmp/ && \
#	mv -v /tmp/spark-$SPARK_VERSION-bin-without-hadoop $SPARK_HOME


#####################################################################

# Configuración para correr los daemons de hadoop en supervisord

ENV HADOOP_USER_HDFS hdfs
ENV HADOOP_USER_YARN yarn
ENV HADOOP_USER_MAPRED mapred
ARG HADOOP_GROUP=hadoop
ARG group=hadoop

RUN groupadd -g 1001 $HADOOP_GROUP \ 
	&& useradd -d /home/$HADOOP_USER_HDFS -m -u 1001 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_HDFS $HADOOP_USER_HDFS \
	&& useradd -d /home/$HADOOP_USER_YARN -m -u 1002 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_YARN $HADOOP_USER_YARN \
	&& useradd -d /home/$HADOOP_USER_MAPRED -m -u 1003 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_MAPRED $HADOOP_USER_MAPRED \
	&& echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' > $HADOOP_HOME/etc/hadoop/hadoop-env.sh  \
	&& echo 'export HDFS_NAMENODE_USER=$HADOOP_USER_HDFS' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
	&& echo 'export HDFS_DATANODE_USER=$HADOOP_USER_HDFS' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
	&& echo 'export HDFS_SECONDARYNAMENODE_USER=$HADOOP_USER_HDFS' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
	&& source $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
	&& mkdir -p /var/log/hadoop-hdfs \ 
	&& mkdir -p /var/log/hadoop-yarn/ \
	&& mkdir -p /var/log/hadoop-mapreduce/ \
	&& mkdir -p /dfs/name \
	&& mkdir -p /dfs/data \ 
	&& chown -R  hdfs:hadoop /dfs \
	&& mkdir -p $HADOOP_HOME/logs \
	&& chown -R  hdfs:hadoop $HADOOP_HOME \
	&& chgrp -R hadoop /usr/local/hadoop/logs \ 
	&& chmod -R 770 /usr/local/hadoop/logs

COPY config/supervisord/ /etc/

ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

############################################################

# Descargar Kerberos 


RUN yum -y install \
        krb5-server \
        krb5-workstation \
	krb5-libs \ 
	krb5-auth-dialog \
    && \
    yum clean all && \
    rm -rf /var/cache/yum/*

## KERBEROS VARIABLES
# REALM 	the Kerberos realm
ENV KRB_REALM EXAMPLE.COM
# DOMAIN_REALM 	the DNS domain for the realm
ENV DOMAIN_REALM example.com
# KERB_MASTER_KEY 	master key for the KDC
ENV KERB_MASTER_KEY masterkey
# KERB_ADMIN_USER 	administrator account name
ENV KERBEROS_ADMIN root
# KERB_PRINCIPAL_USER
ENV KERBEROS_ADMIN root/admin
# KERBEROS_ADMIN_PASSWORD administrator account pass
ENV KERBEROS_ADMIN_PASSWORD admin
# KEYTAB_DIR 
ENV KEYTAB_DIR /var/keytabs
# config kerberos
COPY config/kerberos/kdb.conf /var/lib/krb5kdc/kdb.conf
COPY config/kerberos/kdc.conf /var/kerberos/krb5kdc/kdc.conf

RUN mkdir -p /var/log/kerberos \
	&& mkdir -p ${KEYTAB_DIR} 
	
# config ssh
RUN ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_rsa_key \
	&& ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_ecdsa_key \
	&& ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_ed25519_key \
	&& su - $HADOOP_USER_HDFS -c "ssh-keygen -t rsa -P '' -f /home/$HADOOP_USER_HDFS/.ssh/id_rsa" \
	&& su - $HADOOP_USER_YARN -c "ssh-keygen -t rsa -P '' -f /home/$HADOOP_USER_YARN/.ssh/id_rsa" \
	&& su - $HADOOP_USER_MAPRED -c "ssh-keygen -t rsa -P '' -f /home/$HADOOP_USER_MAPRED/.ssh/id_rsa" \
	&& cp /home/$HADOOP_USER_HDFS/.ssh/id_rsa.pub  /home/$HADOOP_USER_HDFS/.ssh/authorized_keys \
	&& cp /home/$HADOOP_USER_YARN/.ssh/id_rsa.pub  /home/$HADOOP_USER_YARN/.ssh/authorized_keys \
	&& cp /home/$HADOOP_USER_MAPRED/.ssh/id_rsa.pub  /home/$HADOOP_USER_MAPRED/.ssh/authorized_keys \
	&& echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

############################################################
# Install the JCE
RUN cd /tmp/ && \
   curl -LO "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" -H 'Cookie: oraclelicense=accept-securebackup-cookie' && \
   unzip jce_policy-8.zip && \
   rm jce_policy-8.zip && \
   yes |cp -v /tmp/UnlimitedJCEPolicyJDK8/*.jar $JAVA_HOME/lib/security/

############################################################
# Establecer Puertos

# Por último dejamos abiertos unos cuantos puertos. En principio no son necesarios todos, pero los dejo así por si en un futuro los necesito.
EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

# start hadoop
CMD bash $HADOOP_HOME/etc/hadoop/docker-entrypoint.sh
