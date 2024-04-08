#!/bin/bash

# Setup Hostname
sudo hostnamectl set-hostname "$1"

# Update the hostname part of Host File
echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts

# Refresh
/bin/bash