#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER="roboshop"
MONGODB_HOST="mongodb.royalreddy.co.in"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 .. $R FAILED $N"
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: provide root access to the script$N"
    exit 1 
fi

# disable default nodejs module
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "disable nodejs process"

# enable default nodejs 1.18 module
dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "enable nodejs 1.18 versioprocess"

# check nodejs installed already
yum list installed nodejs &>> $LOG_FILE
if [ $? -eq 0 ]
then 
    echo -e "nodejs already installed so $Y SKIPPED $N"
    # exit 1
fi

# install nodejs
dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Install Nodejs process"

# add roboshop user but before check it 
id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    useradd $USER
else   
    echo -e "User roboshop Already exist : $Y SKIPPED $N"
fi

# make directiory with the name of APP
mkdir -p /app

# Download application code
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE

# change directory to app
cd /app 

# unzip code file
unzip -o /tmp/catalogue.zip 

# change directory app
cd /app

# Install all dependencies
npm install &>> $LOG_FILE
VALIDATE $? "Install dependencies"

cp /home/centos/project-shell/catalogue.service /etc/systemd/system/ &>> $LOG_FILE
VALIDATE $? "copy catelogue server to systemd file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "daemon-reload process"

systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "enable catalogue process"

systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "start catalogue process"

cp /home/centos/project-shell/mongo.repo /etc/yum.repos.d/ &>> $LOG_FILE
VALIDATE $? "copy mongorepo process"

# Install mongodb client
dnf install mongodb-org-shell -y &>> $LOG_FILE
VALIDATE $? "mongodb clinet install"

# load scema 
mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOG_FILE
VALIDATE $? "mongodb schema loaded"