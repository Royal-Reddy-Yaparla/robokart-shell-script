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

echo "script started at $TIMESTAMP" &>> $LOG_FILE

# Validate command
VALIDATE(){
    if [ $1 -ne 0 ]
    then   
        echo -e "$2 process $R FAILED $N"
    else
        echo -e "$2 process $G SUCCESS $N"
    fi
}


# Check root access to script
if [ $ID -ne 0 ]
then 
    echo -e "$R Error:: Provide root accuess to the script $N" 
    exit 1
fi

# Set up host
sh /home/centos/project-shell/set_up_host.sh "mongodb_server" &>> $LOG_FILE

# Copy mongo.repo to /etc/yum.repos.d/
cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "Copy mongo.repo"