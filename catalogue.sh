#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: Nodejs install and configuration for catalogue service 
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
    echo -e "$R Error:: Provide root accuss to the script $N" 
    exit 1
fi

# Disable nodejs default version
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disable nodejs default version"

# Enable nodejs 1.18 version
dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "Enable nodejs 1.18 version"


# Install nodejs check before install 
yum list installed nodejs &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install nodejs -y  &>> $LOG_FILE
    VALIDATE $? "Install nodejs"
else    
    echo -e "nodejs already Installed $Y SKIPPING $N"
fi

# Create user with name of roboshop
id "roboshop" &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    useradd roboshop  &>> $LOG_FILE
    VALIDATE $? "create user"
else    
    echo -e "user already exits $Y SKIPPING $N"
fi

# Create directory if exist avoid
mkdir -p /app &>> $LOG_FILE

# Download the application code to created app directory
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE
VALIDATE $? "download the application code"

# Change directory to app
cd /app 

# Unzip app code file
unzip -o /tmp/catalogue.zip &>> $LOG_FILE 
VALIDATE $? "unzipping"


# Install package dependencies
npm install  &>> $LOG_FILE
VALIDATE $? "package dependences"

# Copy catalogue server file
cp /home/centos/project-shell/catalogue.service /etc/systemd/system/  &>> $LOG_FILE
VALIDATE $? "coping catalogue service file"

# Load service
systemctl daemon-reload  &>> $LOG_FILE
VALIDATE $? "Load catalogue service"

# Enable catalogue
systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "Enable catalogue"

# Start catalogue
systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Start catalogue"

# Copy mongo.repo to /etc/yum.repos.d/
cp /home/centos/project-shell/mongo.repo /etc/yum.repos.d/ &>> $LOG_FILE
VALIDATE $? "Copy mongo.repo"


# Install mongodb client
dnf install mongodb-org-shell -y &>> $LOG_FILE
VALIDATE $? "Install mongodb client" 

# Load Schema
mongo --host mongodb.royalreddy.co.in </app/schema/catalogue.js &>> $LOG_FILE
VALIDATE $? "load shcema" 