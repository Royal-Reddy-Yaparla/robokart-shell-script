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

# # Set up host
# sudo sh /home/centos/project-shell/set_up_host.sh "mongodb_server" &>> $LOG_FILE

# Copy mongo.repo to /etc/yum.repos.d/
cp mongo.repo /etc/yum.repos.d/ &>> $LOG_FILE
VALIDATE $? "Copy mongo.repo"

# Install mongodb check before install 
yum list installed mongod
if [ $ID -ne 0 ]
then 
    dnf install mongodb-org -y  &>> $LOG_FILE
    VALIDATE $? "Install mongodb"
else    
    echo -e "monogodb already Installed $Y SKIPPING $N"
fi

# Enable mongodb
systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enable mongodb"

# Start mongodb
systemctl start mongod &>> $LOG_FILE
VALIDATE $? "Start mongodb"

# Provide access this service to be accessed by another server(remote server)
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "Provide access remote server"

# Restart mongodb
systemctl restart mongod
VALIDATE $? "restart mongodb"