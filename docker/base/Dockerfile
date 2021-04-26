FROM centos:7

USER root

RUN yum -y install epel-release \
        curl \
	ssh \
	sudo \ 
        python \
        python-dev \
 	python-pip \
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

# Descargar Hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_VERSION 3.2.2
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

RUN set -x \
    && wget -q "$HADOOP_URL" -O /tmp/hadoop.tar.gz \
    && tar -xzf /tmp/hadoop.tar.gz -C /tmp/ \
    && mv /tmp/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# Descargar Spark
ENV SPARK_HOME /usr/local/spark
ENV SPARK_VERSION 3.1.1
ENV SPARK_URL https://mirrors.estointernet.in/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz

RUN wget -q "$SPARK_URL" && \
	tar -xvf spark-$SPARK_VERSION-bin-without-hadoop.tgz && \
	mv -v spark-$SPARK_VERSION-bin-without-hadoop.tgz $SPARK_HOME


# La ejecución de Hadoop en modo pseudo-distribuido requiere ssh. 
# Añade lo siguiente a ~/.ssh/config para evitar tener que confirmar manualmente la conexión
# Creamos las claves ssh necesarias para que se comunique el NameNode con los demas componentes.
# Al tener todos las mismas claves e incluirlas como claves autorizadas, el acceso ssh entre los distintos nodos está garantizado.

COPY config/ssh_config /etc/ssh/ssh_config

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

# Copiamos los ficheros de configuración y scripts que tenemos en el directorio config al directorio de hadoop
# Más adelante debería explicar cada fichero y su contenido...

ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/docker-entrypoint.sh $HADOOP_HOME/etc/hadoop/

# Configuración para correr los daemons de hadoop 

ARG user_1=hdfs
ARG user_2=yarn
ARG user_3=mapred
ARG group=hadoop
ARG uid_1=1000
ARG uid_2=1001
ARG uid_3=1002
ARG gid=1000

RUN groupadd -g ${gid} ${group} && useradd -u ${uid_1} -g ${group} -s /bin/sh ${user_1} && \
	useradd -u ${uid_2} -g ${group} -s /bin/sh ${user_2} && \
	useradd -u ${uid_3} -g ${group} -s /bin/sh ${user_3}

RUN mkdir -p /var/log/hadoop-hdfs && \ 
	mkdir -p /var/log/hadoop-yarn/ && \
	mkdir -p /var/log/hadoop-mapreduce/ && \
	mkdir -p /dfs/name && \
	mkdir -p /dfs/data && \ 
	chown -R  hdfs:hadoop /dfs && \
	mkdir -p $HADOOP_HOME/logs && \
	chown -R  hdfs:hadoop $HADOOP_HOME && \
	chgrp -R hadoop /usr/local/hadoop/logs && \ 
	chmod -R 770 /usr/local/hadoop/logs

COPY config/supervisord/ /etc/

ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

# Por último dejamos abiertos unos cuantos puertos. En principio no son necesarios todos, pero los dejo así por si en un futuro los necesito.
EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22


# start hadoop
CMD bash /usr/local/hadoop/etc/hadoop/docker-entrypoint.sh
