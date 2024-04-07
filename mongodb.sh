#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "mongo repo file create process"

