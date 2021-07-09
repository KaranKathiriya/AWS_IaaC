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
# Server Name and check if already exists

existing_server="running"      # Initalised "running" to allow it enter the loop for first time

while [[ $existing_server == "running" ]]
do
    printf "Enter Server Name (example: stagingX.karan.com) : "
    read SERVER_NAME

    existing_server=$(helpers/checkIfServerExists.sh $SERVER_NAME)
done

if [[ $SERVER_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Server Name not entered\n\n"
    exit 1
fi

# Create staging Server
read -n 1 -s -r -p "Press any key to continue\n"

printf "Enter New Stack Name for Staging Server (example: stagingX-karan) : "
read stackName

if [[ $stackName == "" ]]
then
    printf "\nFATAL EXCEPTION: Stack Name not entered\n\n"
    exit 1
fi


aws cloudformation create-stack --stack-name $stackName --template-body file://generated/finished/stagingserver_cloudformation.yml

# Wait until Stack create is completed
aws cloudformation wait stack-create-complete --stack-name $stackName
printf "\n\n"
read -n 1 -s -r -p "If [Waiter StackCreateComplete failed] please exit else press any key to continue"


printf "Staging server is now running (Note: userdata may still be installing services on the server)\n"


# Extracting instance_id
instance_id=$(helpers/serverGetIdFromStack.sh $stackName)

# Extracting PublicIpAddress
staging_public_ip=$(helpers/serverGetIp.sh $instance_id)

# Coniguring virtual host
scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/karan_conf/api.karan.conf ec2-user@$staging_public_ip:/home/ec2-user
scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/karan_conf/karan.conf ec2-user@$staging_public_ip:/home/ec2-user
scp -i $KEY_PAIR /karan_install/tpl_aws_netops/bootstrap/staging/stagingServerConfig.sh ec2-user@$staging_public_ip:/home/ec2-user
sudo ssh -i $KEY_PAIR ec2-user@$staging_public_ip \
"sudo chmod +x /home/ec2-user/stagingServerConfig.sh & sudo /home/ec2-user/stagingServerConfig.sh"

#Configuring cname and Tags
printf "Hostname changed from Staging server ip: $staging_public_ip to $SERVER_NAME\n"
sudo ssh -i $KEY_PAIR ec2-user@$staging_public_ip "sudo hostnamectl set-hostname $SERVER_NAME"
helpers/configure_cname_route53.sh $SERVER_NAME $staging_public_ip $HOSTED_ZONE_ID $instance_id "staging"
