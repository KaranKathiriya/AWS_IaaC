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
# AWS credentials saved to server
mkdir ~/.aws
printf "[default]\naws_access_key_id=AKIA4DOVSVNS5TC737OZ\naws_secret_access_key=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\n" >> ~/.aws/credentials
printf "[default]\nregion=us-east-1\noutput=json\n" >> ~/.aws/config
# GIT
sudo yum install git -y
sudo git config –global color.status false
sudo git config –global color.branch false
sudo git config –global color.diff false
sudo git config –global color.interactive false
sudo git config –global color.status false
# Install nodeJs
curl -sL https://rpm.nodesource.com/setup_12.x | bash -
yum install nodejs -y
# Gitlab repos to clone
git clone https://tpl.gitlab:hauntcopeactivate@gitlab.com/shawnchong/tpl_admin_node_server.git /tpl_admin_node_server
git clone https://tpl.gitlab:hauntcopeactivate@gitlab.com/shawnchong/tpl_admin_server.git /var/www/html/tpl_admin_server
git clone https://tpl.gitlab:hauntcopeactivate@gitlab.com/shawnchong/tpl_conf.git /var/www/html/tpl_conf
git clone https://tpl.gitlab:hauntcopeactivate@gitlab.com/harshit4/karan.git /var/www/html/karan
git clone https://tpl.gitlab:hauntcopeactivate@gitlab.com/shawnchong/tpl_docuwiki.git /var/www/html/wiki

# Apache /etc/httpd/conf/httpd.conf file
sed -i 's@DocumentRoot \"/var/www/html\"@DocumentRoot \"/var/www/html/tpl_admin_server\"@' /etc/httpd/conf/httpd.conf
printf "\n<Directory \"/var/www/html/wiki/\">\n   Options Indexes FollowSymLinks Includes ExecCGI\n   AllowOverride All\n   Require all granted\n</Directory>\n" >> /etc/httpd/conf/httpd.conf
printf "\n<Directory \"/var/www/html/tpl_conf/\">\n   Options Indexes FollowSymLinks Includes ExecCGI\n   AllowOverride All\n   Require all granted\n</Directory>\n" >>/etc/httpd/conf/httpd.conf
printf "\n<IfModule alias_module>\n   Alias /wiki \"/var/www/html/wiki/dokuwiki/\"\n</IfModule>\n" >> /etc/httpd/conf/httpd.conf

# Chown wiki directory to apache so wiki can be pushed
chown -R apache:apache /var/www/html/wiki/
chown -R apache:apache /var/www/html/wiki/.git

# Configure and run admin node server
cd /tpl_admin_node_server
npm init -y
npm install express --save
npm install redis
npm install phin
node AdminNodeServer.js

# Get Secret key into tpl file
mkdir /usr/share/httpd/.ssh
sudo chown -R ec2-user /usr/share/httpd/.ssh

# Restart apache server
service httpd restart