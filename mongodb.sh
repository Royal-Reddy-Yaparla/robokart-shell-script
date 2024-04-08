#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 08-04
# Version: V1
# Purpose: MongoDB install and configuration
################################################

# set up host
sh /home/centos/project-shell "mongodb_server"

ID=$(id -u)

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Check root access to script
if [ $ID -ne 0 ]
then 
    echo -e "$R Error:: Provide root accuess to the script $N" 
fi
