#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: Nginx install and configuration 
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
    echo -e "$R Error:: Provide root access to the script $N" 
    exit 1
fi

# Install nginx check before install 
yum list installed nginx &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install nginx -y  &>> $LOG_FILE
    VALIDATE $? "Install nginx"
else    
    echo -e "nginx already Installed $Y SKIPPING $N"
fi

# Enable nginx
systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enable nginx"

# Start nginx
systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Start nginx"

# Remove nginx root content 
rm -rf /usr/share/nginx/html/*
VALIDATE $? "Remove nginx root content"

# Download frontend code
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE
VALIDATE $? "Download frontend code"

# Extract the codefile
cd /usr/share/nginx/html &>> $LOG_FILE
VALIDATE $? "Extract the codefile"

# Unzip
unzip -o /tmp/web.zip &>> $LOG_FILE
VALIDATE $? "unzip"

# Copy Nginx Reverse Proxy Configuration to /etc/nginx/default.d/
cp /home/centos/project-shell/roboshop.conf /etc/nginx/default.d/ &>> $LOG_FILE
VALIDATE $? "Copy Nginx Reverse Proxy Configuration"


# Restart Nginx
systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "Restart Nginx"