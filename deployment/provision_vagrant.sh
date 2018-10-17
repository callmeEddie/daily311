#!/usr/bin/env bash

# Variables
PG_VERSION=9.5
PROJECT_NAME=daily311
ENV_USERNAME=ubuntu


# 
# Create a symbolic link to the working directory
# 
ln -s /vagrant /$PROJECT_NAME


# 
# Keep package list information up to date
# 
sudo apt-get update


# 
# Utilities
# 
sudo apt-get install -y build-essential # Required for building ANYTHING on ubuntu
sudo apt-get install -y git


# 
# Setup Python
# 
sudo apt-get install -y python3-pip
sudo pip3 install --upgrade pip


# 
# Install Nginx
# 
sudo apt-get install -y nginx
sudo cp /$PROJECT_NAME/deployment/nginx_conf_vagrant /etc/nginx/sites-available/$PROJECT_NAME
sudo ln -s /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/


# 
# Install Python packages
# 
sudo pip3 install -r /$PROJECT_NAME/requirements.txt
