#!/bin/sh

HOSTED_ZONE_ID=$1
KEY_PAIR=$2

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

printf "Enter Server Name (example: adminX.karan.com) :"
read SERVER_NAME

if [[ $SERVER_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Server Name not entered\n\n"
    exit 1
fi


#
# Start Admin Server
read -n 1 -s -r -p "Press any key to continue"

printf "Enter Stack Name for Admin Server (example: adminX-karan-com) :"
read stackName

if [[ $stackName == "" ]]
then
    printf "\nFATAL EXCEPTION: Stack Name not entered\n\n"
    exit 1
fi
aws cloudformation create-stack --stack-name $stackName --template-body file://generated/finished/adminserver_cloudformation.yml

# Check if Stack create completed
aws cloudformation wait stack-create-complete --stack-name $stackName

printf "\n\n"

read -n 1 -s -r -p "If [Waiter StackCreateComplete failed] please exit else press any key to continue"

printf "Admin server is now running (Note: userdata may still be installing services on the server)\n"

# Extracting instance_id
instance_id=$(helpers/serverGetIdFromStack.sh $stackName)

# Extracting PublicIpAddress
admin_public_ip=$(helpers/serverGetIp.sh $instance_id)

# TODO: why are we storing the pem file in /var/www/tpl?
# cp $KEY_PAIR /var/www/tpl

scp -i $KEY_PAIR /var/www/tpl ec2-user@$admin_public_ip:/usr/share/httpd/.ssh
printf "Keypair copied to admin for netops ssh functionality.\n"

#Configuring cname

printf "Hostname changed from Admin server ip: $admin_public_ip to $SERVER_NAME\n"
sudo ssh -i $KEY_PAIR ec2-user@$admin_public_ip "sudo hostnamectl set-hostname $SERVER_NAME"

# Adding file for nuxt configuration

scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/admin/nuxtConfig.sh ec2-user@$admin_public_ip:/home/ec2-user
printf "Keypair copied to nuxt config filefor configuration .\n"


# Create an Elastic ip for Admin Server
printf "\nType yes to Create an elastic IP"
read get_eip
if [[ $get_eip == "yes" ]]
then
    # Create an Elastic IP
    helpers/createElasticIP.sh
fi

if [[ $get_eip == "yes" ]]
then
    # Attaching Elastic IP to Admin Server
    printf "Type Elastic ip : "
    read eip
    # Associating IP with Instance
    printf "Assosciating elastic IP with admin server.\n"
    aws ec2 associate-address --instance-id $instance_id --public-ip $eip
    helpers/configure_cname_route53.sh $SERVER_NAME $eip $HOSTED_ZONE_ID $instance_id "admin"
else
    helpers/configure_cname_route53.sh $SERVER_NAME $admin_public_ip $HOSTED_ZONE_ID $instance_id "admin"
fi


# NOTE: tpl-conf should have updated redis server name

printf "\nDo you want to populate redis"
read populate_redis
if [[ $populate_redis == "yes" ]]; then
    scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/admin/redisConfig.sh ec2-user@$admin_public_ip:/home/ec2-user
    sudo ssh -i $KEY_PAIR ec2-user@$utility_public_ip "chmod +x /home/ec2-user/redisConfig.sh"
    sudo ssh -i $KEY_PAIR ec2-user@$utility_public_ip "sudo /home/ec2-user/redisConfig.sh"
fi