#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: RabbitMQ install and configuration
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

# Configure YUM Repos from the script provided by vendor
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOG_FILE
VALIDATE $? "Configure YUM Repos"

# Configure YUM Repos for RabbitMQ.
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOG_FILE
VALIDATE $? "Configure YUM Repos"

# Install RabbitMQ check before install 
yum list installed rabbitmq-server &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    dnf install rabbitmq-server -y &>> $LOG_FILE
    VALIDATE $? "Install mongodb"
else    
    echo -e "Rabbitmq already Installed $Y SKIPPING $N"
fi

# Enable rabbitmq-server 
systemctl enable rabbitmq-server  &>> $LOG_FILE
VALIDATE $? "Enable rabbitmq-server "

# Start rabbitmq-server 
systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Start rabbitmq-server"

# Create one user for the application
rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
VALIDATE $? "Create one user"

# Provide permison to user
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "set permissions user"