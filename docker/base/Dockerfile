FROM ubuntu:16.04
MAINTAINER bruzzese

RUN apt-get update && apt-get install -y curl tree nano net-tools iputils-ping
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget

ENV HADOOP_VERSION 3.2.2
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && tar -xzvf /tmp/hadoop.tar.gz -C /usr/local/ \
    && rm /tmp/hadoop.tar.gz*

RUN ln -s /usr/local/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop

RUN mkdir -p /usr/local/hadoop-$HADOOP_VERSION/logs

RUN mkdir -p /hadoop-data

# Establecemos las variables de entorno JAVA_HOME apuntando a la ruta del JDK, HADOOP_HOME apuntando a 
# la ruta en la que hemos copiado Hadoop e incluimos en la variable PATH las rutas con los binarios y # scripts para gestionar Hadoop.

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
# ENV HADOOP_HOME/hadoop 
ENV HADOOP_HOME=/usr/local/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_HOME/bin/:$PATH
#ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# Creamos las claves ssh necesarias para que se comunique el nodo master con los nodos slaves.
# Al tener todos las mismas claves e incluirlas como claves autorizadas, el acceso ssh entre los distintos nodos está garantizado.
# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Creamos los directorios para los namenodes, y los datanodes
RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && 

# Copiamos los ficheros de configuración y scripts que tenemos en el directorio config al directorio /tmp. 
# De ahí los vamos moviendo cada uno a su ubicación final. Más adelante explico cada fichero y su contenido.
COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# Formateamos el sistema de ficheros de hadoop.
RUN /usr/local/hadoop/bin/hdfs namenode -format

# Como proceso de los contenedores configuramos el demonio de ssh. 
# As’el nodo master podrá acceder a los nodos slave para arrancar los procesos de Hadoop necesarios para que formen parte del cluster.

CMD [ "sh", "-c", "service ssh start; bash"]

# Por último dejamos abiertos unos cuantos puertos. En principio no son necesarios todos, pero los dejo así por si en un futuro los necesito.

# Hdfs ports
EXPOSE 9000 50010 50020 50070 50075 50090
EXPOSE 9871 9870 9820 9869 9868 9867 9866 9865 9864
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8188
#Other ports
EXPOSE 49707 2122
