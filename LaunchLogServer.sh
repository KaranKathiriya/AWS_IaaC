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

printf "Enter Server Name (example: logX.karan.com) : "
read SERVER_NAME

if [[ $SERVER_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Server Name not entered\n\n"
    exit 1
fi

# Create log Server
read -n 1 -s -r -p "Press any key to continue"

printf "Enter New Stack Name for Log Server (example: logX-karan) : "
read stackName

if [[ $stackName == "" ]]
then
    printf "\nFATAL EXCEPTION: Stack Name not entered\n\n"
    exit 1
fi


aws cloudformation create-stack --stack-name $stackName --template-body file://generated/finished/logserver_cloudformation.yml

# Wait until Stack create is completed
aws cloudformation wait stack-create-complete --stack-name $stackName
printf "\n\n"
read -n 1 -s -r -p "If [Waiter StackCreateComplete failed] please exit else press any key to continue"


printf "Log server is now running (Note: userdata may still be installing services on the server)\n"


# Extracting instance_id
instance_id=$(helpers/serverGetIdFromStack.sh $stackName)

# Extracting PublicIpAddress
log_public_ip=$(helpers/serverGetIp.sh $instance_id)


#Configuring cname and Tags

printf "Hostname changed from Log server ip: $log_public_ip to $SERVER_NAME\n"
sudo ssh -i $KEY_PAIR ec2-user@$log_public_ip "sudo hostnamectl set-hostname $SERVER_NAME"
helpers/configure_cname_route53.sh $SERVER_NAME $log_public_ip $HOSTED_ZONE_ID $instance_id "log"
