#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: Dispatch service configuration
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
        exit 1
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



# Install golang check before install 
yum list installed golang &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install golang -y  &>> $LOG_FILE
    VALIDATE $? "Install golang"
else    
    echo -e "golang already Installed $Y SKIPPING $N"
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
curl -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOG_FILE
VALIDATE $? "download the application code"

# Change directory to app
cd /app 

# Unzip app code file
unzip -o /tmp/dispatch.zip &>> $LOG_FILE 
VALIDATE $? "unzipping"

# Init the dependenciess
go mod init dispatch &>> $LOG_FILE 
VALIDATE $? "Init the dependencies"

# Download dependencies
go get &>> $LOG_FILE 
VALIDATE $? "Download dependencies"

# Build
go build &>> $LOG_FILE 
VALIDATE $? "Build the application"

# Copy dispatch server file
cp /home/centos/project-shell/dispatch.service /etc/systemd/system/  &>> $LOG_FILE
VALIDATE $? "coping dispatch service file"

# Load service
systemctl daemon-reload  &>> $LOG_FILE
VALIDATE $? "Load dispatch service"

# Enable dispatch
systemctl enable dispatch &>> $LOG_FILE
VALIDATE $? "Enable dispatch"

# Start dispatch
systemctl start dispatch &>> $LOG_FILE
VALIDATE $? "Start dispatch"