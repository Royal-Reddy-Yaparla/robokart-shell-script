#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: MongoDB install and configuration
################################################

ID=$(id -u)

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"


exec &> $LOG_FILE
echo "script started at $TIMESTAMP"

# Check root access to script
if [ $ID -ne 0 ]
then 
    echo -e "$R Error:: Provide root accuess to the script $N" 
    exit 1
fi

# set up host
sh /home/centos/project-shell/set_up_host.sh "mongodb_server"