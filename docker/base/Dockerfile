FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
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
	openjdk-8-jdk \ 
	wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install -U setuptools && \
    pip install -U supervisor

# Establecemos las variables de entorno JAVA_HOME apuntando a la ruta del JDK, HADOOP_HOME apuntando a 
# la ruta en la que hemos copiado Hadoop e incluimos en la variable PATH las rutas con los binarios y # scripts para gestionar Hadoop.

USER root
ENV HADOOP_HOME /usr/local/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_VERSION 3.2.2
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

RUN set -x \
    && wget -q "$HADOOP_URL" -O /tmp/hadoop.tar.gz \
    && tar -xzf /tmp/hadoop.tar.gz -C /tmp/ \
    && mv /tmp/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# La ejecución de Hadoop en modo pseudo-distribuido requiere ssh. 
# Añade lo siguiente a ~/.ssh/config para evitar tener que confirmar manualmente la conexión
# Creamos las claves ssh necesarias para que se comunique el NameNode con los demas componentes.
# Al tener todos las mismas claves e incluirlas como claves autorizadas, el acceso ssh entre los distintos nodos está garantizado.
COPY config/ssh_config /etc/ssh/ssh_config
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

# Copiamos los ficheros de configuración y scripts que tenemos en el directorio config al directorio de hadoop
# Más adelante debería explicar cada fichero y su contenido...

COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/docker-entrypoint.sh $HADOOP_HOME/etc/hadoop/

# Configuración para correr los daemons de hadoop 

RUN useradd -m hdfs && echo "hdfs:supergroup" | chpasswd && adduser hdfs sudo && echo "hdfs     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ 
 
RUN useradd -m yarn && echo "yarn:supergroup" | chpasswd && adduser yarn sudo && echo "yarn     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ 

RUN mkdir -p /var/log/hadoop-yarn/ && \
	mkdir -p /var/log/hadoop-hdfs/ 

COPY config/supervisord/ /etc/

ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root

ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root

ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Por último dejamos abiertos unos cuantos puertos. En principio no son necesarios todos, pero los dejo así por si en un futuro los necesito.
EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

# start hadoop
CMD bash /usr/local/hadoop/etc/hadoop/docker-entrypoint.sh
