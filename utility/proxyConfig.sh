#!/bin/sh

# Install Proxy MYSQL
printf "[proxysql_repo]\nname= ProxySQL YUM repository\nbaseurl=https://repo.proxysql.com/ProxySQL/proxysql-2.0.x/centos/latest\ngpgcheck=1\ngpgkey=https://repo.proxysql.com/ProxySQL/repo_pub_key" >> /etc/yum.repos.d/proxysql.repo
sudo yum install proxysql -y

# Installing MySql
sudo yum install mysql -y

# Start Proxy SQL
sudo service proxysql start

# RDS Delete existing users `monitor` and replace with new user and ip
private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

printf "DROP USER IF EXISTS 'monitor';\n CREATE USER 'monitor'@'$private_ip' IDENTIFIED BY 'monitor';" > change-user.sql

sudo mysql -h {SQL_HOST} -P {SQL_PORT} -u {SQL_USER} -p{SQL_PASS} < change-user.sql

sudo rm change-user.sql
