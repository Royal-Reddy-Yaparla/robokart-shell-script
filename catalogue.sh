#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo "$2 .. $R FAILED $N"
    else
        echo "$2 .. $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo "$R ERROR:: provide root access to the script$N"
    exit 1 
fi

# disable default nodejs module
dnf module disable nodejs -y
VALIDATE $? "disable nodejs process"

# enable default nodejs 1.18 module
dnf module enable nodejs:18 -y
VALIDATE $? "enable nodejs 1.18 versioprocess"

# check nodejs installed already
yum list installed nodejs
if [ $? -eq 0 ]
then 
    echo "nodejs already installed so $Y SKIPPED $N"
    exit 1
fi

dnf install nodejs -y
VALIDATE $? "Install Nodejs process"

