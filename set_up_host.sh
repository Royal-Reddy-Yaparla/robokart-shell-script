#!/bin/bash

# Setup Hostname
sudo hostnamectl set-hostname "$1"

# Refresh
/bin/bash

# switch to root
sudo su

# Update the hostname part of Host File
echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts

# Back to normal user
exit