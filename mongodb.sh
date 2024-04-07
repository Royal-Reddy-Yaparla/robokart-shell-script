#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP"

echo "scripted excuted $TIMESTAMP" &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "ERROR:: $2 ..$R FAILED $N"
        exit 1
    else
        echo -e "$2 .. $G SUCCEESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: prove root access to the script $N"
    exit 1
else
    echo -e "$G you are root user$N"
fi

# setup mongodb repo file
cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "mongo repo file create process"

# check mongodb already installed if not installed install otherwise skip
mongod -version &>> $LOG_FILE

if [ $? -ne 0 ]
then 
    dnf install mongodb-org -y &>> $LOG_FILE
    VALIDATE $? "mongodb Installed "
else
    echo -e "$Y mongodb already installed : SKIPPED$N"
fi

systemctl enable mongod
VALIDATE $? "enable mongod process"

systemctl start mongod
VALIDATE $? "start mongod process"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "provide access to remote servers for mongodb"

systemctl restart mongod
VALIDATE $? "restart mongod process"