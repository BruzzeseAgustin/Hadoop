#!/bin/bash

# create base hadoop cluster docker image
docker build -f docker/base/Dockerfile -t hadoop-cluster-base:latest docker/base

echo "start hadoop-master container..."
docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                --name hadoop-master \
                --hostname hadoop-master \
				-v $PWD/data:/data \
                bruzzese/hadoop-cluster-master

docker run -p 9864:9864 -p 9870:9870 -p 8088:8088 \
	--name hadoop-container \
	-d hadoop-cluster-base:latest


# get into hadoop master container
docker exec -it hadoop-container bash
