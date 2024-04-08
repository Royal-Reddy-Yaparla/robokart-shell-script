#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: RedisDB install and configuration
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

# Install the Remi repository package
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOG_FILE
VALIDATE $? "Install the Remi repo"

# Enable Redis module
dnf module enable redis:remi-6.2 -y &>> $LOG_FILE
VALIDATE $? "Enable Remi module"


# Install Redis check before install 
yum list installed redis &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install redis -y &>> $LOG_FILE
    VALIDATE $? "Install redis"
else    
    echo -e "redis already Installed $Y SKIPPING $N"
fi


# Provide access this service to be accessed by another server(remote server)
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG_FILE
VALIDATE $? "Provide access remote server"

# Enable redis
systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enable redis"

# Start redis
systemctl start redis &>> $LOG_FILE
VALIDATE $? "Start redis"
