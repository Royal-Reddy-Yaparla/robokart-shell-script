#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: Shipping Service configuration
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

# Install maven check before install 
yum list installed maven &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install maven -y -y  &>> $LOG_FILE
    VALIDATE $? "Install maven"
else    
    echo -e "maven already Installed $Y SKIPPING $N"
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
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE
VALIDATE $? "download the application code"

# Change directory to app
cd /app 

# Unzip app code file
unzip -o /tmp/shipping.zip &>> $LOG_FILE 
VALIDATE $? "unzipping"

# Download the dependencies 
mvn clean package &>> $LOG_FILE 
VALIDATE $? "Download the dependencies"

# Build the application
mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE 
VALIDATE $? "Build the application"

# Copy shipping server file
cp /home/centos/project-shell/shipping.service /etc/systemd/system/  &>> $LOG_FILE
VALIDATE $? "coping shipping service file"

# Load service
systemctl daemon-reload  &>> $LOG_FILE
VALIDATE $? "Load shipping service"

# Enable shipping
systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "Enable shipping"

# Start shipping
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "Start shipping"

# Install mysql client.
dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Install mysql client"

# Load Schema
mysql -h mysql.royalreddy.co.in -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOG_FILE
VALIDATE $? "Load Schema"

# Restart Shipping
systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "restart shipping"
