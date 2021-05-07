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
	bzip2 \
	openssh-server \
	less \
	java-11-openjdk-devel \ 
	autoconf \
	libtool \
	make \
	gcc-c++ \
	g++ \ 
	unzip \
	wget \
	nano \
	git \
        && \
    yum clean all && \
    rm -rf /var/cache/yum/*
RUN yum -y install python-pip 

RUN pip install -U supervisor 
# Establecemos las variables de entorno JAVA_HOME apuntando a la ruta del JDK, HADOOP_HOME apuntando a 
# la ruta en la que hemos copiado Hadoop e incluimos en la variable PATH las rutas con los binarios y # scripts para gestionar Hadoop.

# Establecer JAVA
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk

#####################################################################

# Descargar Hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_VERSION 3.2.2
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop

RUN set -x \
	&& wget -q "$HADOOP_URL" -O /tmp/hadoop.tar.gz \
	&& tar -xzf /tmp/hadoop.tar.gz -C /tmp/ \
	&& mv /tmp/hadoop-$HADOOP_VERSION $HADOOP_HOME \
	&& echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_CONF_DIR/hadoop-env.sh \
	&& echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# COPY zip/hadoop.tar.gz /tmp/hadoop.tar.gz
# RUN tar -xzf /tmp/hadoop.tar.gz -C /tmp/ \
#	&& mv /tmp/hadoop-$HADOOP_VERSION $HADOOP_HOME \
#	&& echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_CONF_DIR/hadoop-env.sh \
#	&& echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# Copiamos los ficheros de configuración y scripts que tenemos en el directorio config al directorio de hadoop
# Más adelante debería explicar cada fichero y su contenido...

COPY config/hadoop/core-site.xml $HADOOP_CONF_DIR/core-site.xml
COPY config/hadoop/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
COPY config/hadoop/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml
COPY config/hadoop/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
COPY config/hadoop/docker-entrypoint.sh $HADOOP_CONF_DIR/docker-entrypoint.sh
COPY config/hadoop/container-executor.cfg $HADOOP_CONF_DIR/container-executor.cfg

# La ejecución de Hadoop en modo pseudo-distribuido requiere ssh. 
# Añade lo siguiente a ~/.ssh/config para evitar tener que confirmar manualmente la conexión
# Creamos las claves ssh necesarias para que se comunique el NameNode con los demas componentes.
# Al tener todos las mismas claves e incluirlas como claves autorizadas, el acceso ssh entre los distintos nodos está garantizado.

COPY config/hadoop/ssh_config /etc/ssh/ssh_config

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

#####################################################################
#####################################################################

# Build HIVE and TEZ 

#####################################################################

# Set environment

ENV MAVEN_VERSION=3.6.3
ENV PROTOBUF_VERSION=2.5.0
ENV TEZ_VERSION=0.10.0
ENV HIVE_VERSION=3.1.2
ENV HIVE_DOWNLOAD_DIR=/tmp/hive
ENV POSTGRESQL_JDBC_VERSION=42.2.14
ENV TEZ_HDP_DIR=/app/tez
ENV TEZ_HOME_DIR=/opt/tez
ENV TEZ_LIB_DIR=/opt/tez/lib
ENV TEZ_CONF_DIR=/opt/tez/conf
ENV HADOOP_CLASSPATH=/opt/tez/conf:/opt/tez/*:/opt/tez/lib/

# Descargar maven
# RUN yum install -y maven # this way is not recommended
RUN curl -fSL https://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz --output apache-maven-${MAVEN_VERSION}-bin.tar.gz \ 
	&& tar xvf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /usr/local/ \
	&& mv /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/maven \
	&& ln -s apache-maven-${MAVEN_VERSION} /usr/local/ 

ENV MAVEN_HOME /usr/local/maven
ENV PATH $MAVEN_HOME/bin:$PATH

# Descargar Protoc-compiler

RUN curl -fSL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-${PROTOBUF_VERSION}.tar.gz" --output protobuf-${PROTOBUF_VERSION}.tar.gz \
	&& tar -xvf protobuf-${PROTOBUF_VERSION}.tar.gz \
	&& cd protobuf-${PROTOBUF_VERSION} \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local \
	&& make \
	&& make install \
	&& ldconfig

# Descargar Tez

# to run bower as root
RUN echo '{ "allow_root": true }' > /root/.bowerrc

RUN curl -fSL https://downloads.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-src.tar.gz -o /tmp/tez.tar.gz \
	&& mkdir -pv ${TEZ_CONF_DIR} \
	&& mkdir -pv ${TEZ_HDP_DIR} \
	&& tar -xvf /tmp/tez.tar.gz -C /tmp/ \
	&& cd /tmp/apache-tez-${TEZ_VERSION}-src  \
	&& mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true \
	&& cp -r /tmp/apache-tez-${TEZ_VERSION}-src/tez-dist/target/tez-${TEZ_VERSION}-minimal.tar.gz ${TEZ_HOME_DIR}/tez.tar.gz \
	&& tar -xvf ${TEZ_HOME_DIR}/tez.tar.gz -C ${TEZ_HOME_DIR}/ \
	&& mv /tmp/apache-tez-${TEZ_VERSION}-src/tez-dist/target/tez-${TEZ_VERSION}-minimal.tar.gz ${TEZ_HDP_DIR}/tez.tar.gz \
	&& echo "HADOOP_CLASSPATH=/opt/tez/conf:/opt/tez/*:/opt/tez/lib/*" >> ~/.bashrc

COPY config/hadoop/tez-site.xml ${TEZ_CONF_DIR}

#####################################################################

# Descargar HIVE

# Install Hive and PostgreSQL JDBC
# RUN curl -fSL https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz -o /tmp/hive.tar.gz \
COPY zip/hive.tar.gz /tmp/hive.tar.gz
RUN mkdir -pv $HIVE_DOWNLOAD_DIR \
    && mkdir -pv $TEZ_CONF_DIR \
    && tar -xvf /tmp/hive.tar.gz -C $HIVE_DOWNLOAD_DIR --strip-components=1 \
    && mv -v $HIVE_DOWNLOAD_DIR /opt \
    && rm -rfv /tmp/hive.tar.gz \
    && rm -rfv $HIVE_HOME/lib/guava-*.jar \
    && cp $HADOOP_HOME/share/hadoop/common/lib/guava-*.jar $HIVE_HOME/lib/ \
    && rm -rfv $HIVE_HOME/lib/postgresql-*.jre*.jar \
    && curl -fSL https://jdbc.postgresql.org/download/postgresql-$POSTGRESQL_JDBC_VERSION.jar -o $HIVE_HOME/lib/postgresql-jdbc.jar

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
ENV HADOOP_USER_HTTP HTTP
ENV HADOOP_USER_TEST abruzzese
ENV HADOOP_AUTHENTICATION kerberos
ARG HADOOP_GROUP=hadoop
ARG group=hadoop

RUN groupadd -g 1001 $HADOOP_GROUP \ 
	&& useradd -d /home/$HADOOP_USER_HDFS -m -u 1001 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_HDFS $HADOOP_USER_HDFS \
	&& useradd -d /home/$HADOOP_USER_YARN -m -u 1002 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_YARN $HADOOP_USER_YARN \
	&& useradd -d /home/$HADOOP_USER_MAPRED -m -u 1003 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_MAPRED $HADOOP_USER_MAPRED \
	&& useradd -d /home/$HADOOP_USER_HTTP -m -u 1004 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_HTTP $HADOOP_USER_HTTP \
	&& useradd -d /home/$HADOOP_USER_TEST -m -u 1005 -g $HADOOP_GROUP -s /bin/bash -p $HADOOP_USER_TEST $HADOOP_USER_TEST \
	# && echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' > $HADOOP_HOME/etc/hadoop/hadoop-env.sh  \
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
ENV KERB_PRINCIPAL_USER root/admin
# KERBEROS_ADMIN_PASSWORD administrator account pass
ENV KERBEROS_ADMIN_PASSWORD admin
# KEYTAB_DIR 
ENV KEYTAB_DIR /var/keytabs
# config kerberos
COPY config/kerberos/kdb.conf /var/lib/krb5kdc/kdb.conf
COPY config/kerberos/kdc.conf /var/kerberos/krb5kdc/kdc.conf

RUN mkdir -p /var/log/kerberos \
	&& mkdir -p ${KEYTAB_DIR} \
	&& mkdir -p /tmp/hadoop-yarn/staging/history/done \
	&& mkdir -p /tmp/hadoop-yarn-yarn/staging/history/done \
	&& chown -R  hdfs:hadoop /tmp/ \
	&& chown -R  yarn:hadoop /tmp/hadoop-yarn-yarn/ \
	&& chown -R  yarn:hadoop /tmp/hadoop-yarn/ \
	&& chgrp -R hadoop -R /tmp/ \ 
	&& chmod -R 770 /tmp/
	
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


RUN chown root $HADOOP_CONF_DIR/container-executor.cfg \ 
	&& chown root:hadoop $HADOOP_HOME/bin/container-executor \
	&& chown root:hadoop $HADOOP_HOME \
	&& chown root:hadoop $HADOOP_HOME/etc/ \
	&& chown root:hadoop $HADOOP_HOME/etc/hadoop \ 
	&& chmod 755 $HADOOP_HOME/etc/hadoop/*

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
# Mapred ports
EXPOSE 10020 19888
# Tez ports
EXPOSE 9999
# start hadoop
CMD bash $HADOOP_HOME/etc/hadoop/docker-entrypoint.sh
