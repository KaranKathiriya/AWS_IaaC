#!/bin/sh

HOSTED_ZONE_ID=$1
KEY_PAIR=$2
SQL_HOST=$3;
SQL_USER=$4;
SQL_PASS=$5;
SQL_PORT=$6;


if [[ $HOSTED_ZONE_ID == "" ]]
then
    printf "\nFATAL EXCEPTION: Hosted Zone ID not entered\n\n"
    exit 1
fi

if [[ $KEY_PAIR == "" ]]
then
    printf "\nFATAL EXCEPTION: Key Pair not entered\n\n"
    exit 1
fi

#
# Server Name

printf "Enter Server Name (example: utilityX.karan.com) : "
read SERVER_NAME

if [[ $SERVER_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Server Name not entered\n\n"
    exit 1
fi

if [[ $SQL_HOST == "" ]]; then
    printf "ProxySql Configuration - Enter existing SQL database host: "
    read SQL_HOST
fi

if [[ $SQL_USER == "" ]]; then
    printf "ProxySql Configuration - Enter existing SQL database user: "
    read SQL_USER
fi

if [[ $SQL_PASS == "" ]]; then
    printf "ProxySql Configuration - Enter existing SQL database password: "
    read SQL_PASS
fi

if [[ $SQL_PORT == "" ]]; then
    printf "ProxySql Configuration - Enter existing SQL database port: "
    read SQL_PORT
fi

# Create utility Server
read -n 1 -s -r -p "Press any key to continue"

printf "\nEnter New Stack Name for Utility Server (example: utilityX-karan)"
read stackName

if [[ $stackName == "" ]]
then
    printf "\nFATAL EXCEPTION: Stack Name not entered\n\n"
    exit 1
fi

aws cloudformation create-stack --stack-name $stackName --template-body file://generated/finished/utilityserver_cloudformation.yml

# Wait until Stack create is completed
aws cloudformation wait stack-create-complete --stack-name $stackName

printf "\n\n"
read -n 1 -s -r -p "If [Waiter StackCreateComplete failed] please exit else press any key to continue"

printf "\nUtility server is now running (Note: userdata may still be installing services on the server)"


# Extracting instance_id
instance_id=$(helpers/serverGetIdFromStack.sh $stackName)

# Extracting PublicIpAddress
utility_public_ip=$(helpers/serverGetIp.sh $instance_id)

#Adding Proxy SQL conf File to utlity server
sed -i "s!{SQL_HOST}!$SQL_HOST!g" utility/proxysql.cnf
sed -i "s!{SQL_USER}!$SQL_USER!g" utility/proxysql.cnf
sed -i "s!{SQL_PASS}!$SQL_PASS!g" utility/proxysql.cnf

scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/utility/proxysql.cnf ec2-user@$utility_public_ip:/home/ec2-user
sudo ssh -i $KEY_PAIR ec2-user@$utility_public_ip \
"sudo mv /home/ec2-user/proxysql.cnf /etc"

sed -i "s!{SQL_HOST}!$SQL_HOST!g" utility/proxyConfig.sh
sed -i "s!{SQL_PORT}!$SQL_PORT!g" utility/proxyConfig.sh
sed -i "s!{SQL_USER}!$SQL_USER!g" utility/proxyConfig.sh
sed -i "s!{SQL_PASS}!$SQL_PASS!g" utility/proxyConfig.sh

scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/utility/proxyConfig.sh ec2-user@$utility_public_ip:/home/ec2-user
sudo ssh -i $KEY_PAIR ec2-user@$utility_public_ip \
"chmod +x /home/ec2-user/proxyConfig.sh"
sudo ssh -i $KEY_PAIR ec2-user@$utility_public_ip \
"sudo /home/ec2-user/proxyConfig.sh"

#Configuring cname

printf "Hostname changed from Utility server ip: $utility_public_ip to $SERVER_NAME\n"
sudo ssh -i $KEY_PAIR ec2-user@$utility_public_ip "sudo hostnamectl set-hostname $SERVER_NAME"
helpers/configure_cname_route53.sh $SERVER_NAME $utility_public_ip $HOSTED_ZONE_ID $instance_id "utility"
