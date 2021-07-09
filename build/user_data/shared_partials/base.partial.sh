#!/bin/sh

# AWS cli tools
yum install aws-cli -y

# Create log dir
mkdir -p "/var/app/logs/apiError"
mkdir -p "/var/app/logs/apiException"
mkdir -p "/var/app/logs/apiTime"
mkdir -p "/var/app/logs/rateLimited"
chmod -R 777 /var/app/logs

# Install required yum packages
sudo yum update -y
sudo yum install httpd -y
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable php7.3
sudo yum install php -y
sudo yum install php-xml -y

# Mysql
sudo yum install mysql -y

# Redis
sudo yum install gcc gcc-c++ make -y
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz 
cd redis-stable && make
sudo cp src/redis-cli /usr/bin/ && cd /
sudo rm -rf redis-stable*

# PHP required modules
yum install php-mysqli -y
sudo yum install php-pecl-redis -y
