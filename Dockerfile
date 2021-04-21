FROM ubuntu:16.04
MAINTAINER Agus

RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget

# install hadoop 2.7.2
RUN wget http://apache.rediris.es/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz && \
    tar -xzvf hadoop-2.7.7.tar.gz && \
    mv hadoop-2.7.7 /usr/local/hadoop && \
    rm hadoop-2.7.7.tar.gz

# Establecemos las variables de entorno JAVA_HOME apuntando a la ruta del JDK, HADOOP_HOME apuntando a 
# la ruta en la que hemos copiado Hadoop e incluimos en la variable PATH las rutas con los binarios y # scripts para gestionar Hadoop.

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# Creamos las claves ssh necesarias para que se comunique el nodo master con los nodos slaves.
# Al tener todos las mismas claves e incluirlas como claves autorizadas, el acceso ssh entre los distintos nodos está garantizado.
# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Creamos los directorios para los namenodes, los datanodes y los logs de Hadoop
RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Copiamos los ficheros de configuración y scripts que tenemos en el directorio config al directorio /tmp. 
# De ahí los vamos moviendo cada uno a su ubicación final. Más adelante explico cada fichero y su contenido.
COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

