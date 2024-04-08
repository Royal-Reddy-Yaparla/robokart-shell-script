#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: payment service configuration 
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

# Install Python 3.6
dnf install python36 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Install Python"

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
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG_FILE
VALIDATE $? "download the application code"

# Change directory to app
cd /app 

# Unzip app code file
unzip -o /tmp/payment.zip &>> $LOG_FILE 
VALIDATE $? "unzipping"


# Install package dependencies
pip3.6 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "package dependences"

# Copy payment server file
cp /home/centos/project-shell/payment.service /etc/systemd/system/  &>> $LOG_FILE
VALIDATE $? "coping payment service file"

# Load service
systemctl daemon-reload  &>> $LOG_FILE
VALIDATE $? "Load payment service"

# Enable payment
systemctl enable payment &>> $LOG_FILE
VALIDATE $? "Enable catalogue"

# Start payment
systemctl start payment &>> $LOG_FILE
VALIDATE $? "Start payment"
