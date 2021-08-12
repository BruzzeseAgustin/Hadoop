#!/bin/bash

while true; do 
	if output=$(netstat -tulpn | grep 18080); then
		printf 'history server running corretly, the output was «%s»\n' "$output"
	else
		while ! output=$(netstat -tulpn | grep 18080)
		do 
		printf 'fail to start history server'
		/usr/local/spark/sbin/start-history-server.sh
		done
	fi
	sleep 1 
done
