#!/usr/bin/env bash

export GODOT_DEV_ENV=true

#./stop_all.sh

#logs_folder=`pwd`/logs
#mkdir -p $logs_folder

#echo "Starting server"
#godot $@ > $logs_folder/server.log -server 2>&1 &
#echo $! > ../.godot_pids                                                                                      
godot client
