#!/bin/bash

echo 'y' | docker stop container $(docker container ls -aq)

echo 'y' | docker rm  container $(docker container ls -aq)

