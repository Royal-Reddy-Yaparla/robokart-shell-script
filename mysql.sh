#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: Mysql install and configuration for cart service
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
    echo -e "$R Error:: Provide root access to the script $N" 
    exit 1
fi

# Disable MySQL 8 version
dnf module disable mysql -y
VALIDATE $? "Disable MySQL 8 version"

# Copy mysql.repo to /etc/yum.repos.d/
cp /home/centos/project-shell/mysql.repo /etc/yum.repos.d/ &>> $LOG_FILE
VALIDATE $? "Copy mysql.repo"

# Install Mysql check before install 
yum list installed mysql-community-server &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install mysql-community-server -y  &>> $LOG_FILE
    VALIDATE $? "Install Mysql"
else    
    echo -e "Mysql already Installed $Y SKIPPING $N" 
fi

# Enable Mysql
systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enable mysqld"

# Start mysqld
systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Start mysqld"

# We need to change the default root password in order to start using the database service. 
# Use password RoboShop@1 or any other as per your choice
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "change the default root password"