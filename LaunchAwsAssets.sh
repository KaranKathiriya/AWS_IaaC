#!/bin/sh

vpcId=""

keyPairName=""
keyPairPemData=""

awsAccessKey=""
awsSecret=""
awsRegion=""

#
# Get VPC id

printf "VPCs accessible by this bootstrap server:\n"
helpers/vpcList.sh
printf "Please enter the vpc-id you wish to use: "
read vpcId

helpers/vpcCheck.sh $vpcId
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The vpc-id supplied could not be found by the bootstrap server\n\n"
    exit 1
fi

printf "vpc-id has been validated, continuing with next step\n\n"


#
# Hosted Zone ID

printf "Available hosted zones:\n"
helpers/hostedZoneList.sh

printf "Please enter the hosted zone id: "
read hostedZoneId

helpers/hostedZoneCheck.sh $hostedZoneId

if [[ $? != 0 ]]
then
    printf "\nFATAL EXCEPTION: The HOSTED ZONE ID supplied could not be found by the bootstrap server\n\n"
    exit 1
fi

#
# Get key-pair name

printf "Key-pair names accessible by this bootstrap server:\n"
helpers/keyPairList.sh
printf "Please enter the key-pair you wish to use: "
read keyPairName

helpers/keyPairCheck.sh $keyPairName
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The key-pair name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi

printf "Please enter the path you saved $keyPairName in bootstrap server (eg : / ): "
read keyPairPath

keyPair=$keyPairPath$keyPairName.pem

printf "Key-pair [$keyPairName] is valid and saved at [$keyPair], continuing with next step\n\n"


#
# Get availability zone

printf "Please enter the availability zone you wish to add your servers to: "
read availabilityZone

if [[ $availabilityZone == "" ]]; then
    printf "\nFATAL EXCEPTION: The availability zone cannot be empty\n\n"
    exit 1
fi


#
# Get aws credentials and region

printf "Getting AWS credentials/region from boostrap aws configuration files\n"
awsCredentials=$(helpers/awsConfigGet.sh)
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The key-pair name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi

IFS=";" read -r awsAccessKey awsSecret awsRegion <<< $awsCredentials;
printf "aws credentials successfuly retrieved: $awsAccessKey $awsSecret $awsRegion\n"


#
# Generate CloudFormation scripts from templates

printf "Do you want to generate CloudFormation scripts from templates (yes/no): "
read generateCloudFormationTemplates

if [[ $generateCloudFormationTemplates == "yes" ]] || [[ $generateCloudFormationTemplates == "y" ]]; then
    printf "Trying to generate CloudFormation templates...\n"
    ./generateCloudFormationTemplates.sh $awsAccessKey $awsSecret $awsRegion $vpcId $hostedZoneId $keyPairName $availabilityZone

    if [[ $? != 0 ]]; then
        printf "\nFATAL EXCEPTION: There was an error generation cloud formation scripts from templates\n\n"
        exit 1
    fi
    printf "Generating CloudFormation scripts from templates sucess!\n"
fi


#
# Create Security Groups

printf "Do you want to instantiate all security groups from the yml template (yes/no): "
read instantiateSecurityGroups
if [[ $instantiateSecurityGroups == "yes" ]] || [[ $instantiateSecurityGroups == "y" ]]; then
    build/cloud_formation/generateSecurityGroupYml.sh "$vpcId"
    aws cloudformation create-stack --stack-name create-karan-security-groups --template-body file://generated/finished/instantiate_security_groups.yml
    aws cloudformation wait stack-create-complete --stack-name create-karan-security-groups
    sleep 2s
    printf "Security Groups are Created"
fi

#
# Security Group Rules

printf "Do you want to add security groups rules (yes/no): "
read instantiateSecurityGroupRules
if [[ $instantiateSecurityGroupRules == "yes" ]] || [[ $instantiateSecurityGroupRules == "y" ]]; then
    ./securityGroupRules.sh
    printf "Security Group rules updated"
fi

#
# Add bootstrap to security groups

printf "Do you want to add bootstrap to all security groups rules (yes/no): "
read addBootstrapToSecurityGroups
if [[ $addBootstrapToSecurityGroups == "yes" ]] || [[ $addBootstrapToSecurityGroups == "y" ]]; then
    ./addBootstrapToSecurityGroups.sh
    printf "Security Group rules updated\n"
fi

#
# Running Redis Sever

printf "Create Redis Server (yes/no): "
read get_redis
if [[ $get_redis == "yes" ]] || [[ $get_redis == "y" ]]; then
    chmod +x LaunchRedisServer.sh
    ./LaunchRedisServer.sh "$vpcId"
fi


#
# Running SQL Sever

printf "Create SQL Server (yes/no): "
read get_sql
if [[ $get_sql == "yes" ]] || [[ $get_sql == "y" ]]; then
    chmod +x LaunchSqlServer.sh
    ./LaunchSqlServer.sh "$vpcId"
fi

#
# Create Log Server

printf "Do you want to instantiate log Server (yes/no): "
read instantiateLogServer
if [[ $instantiateLogServer == "yes" ]] || [[ $instantiateLogServer == "y" ]]
then
    chmod +x LaunchLogServer.sh
    ./LaunchLogServer.sh $hostedZoneId $keyPair
    printf "Log Server is Created\n"
fi

#
# Create Admin Server

printf "Do you want to instantiate an admin.karan.com server (yes/no): "
read startAdminServer
if [[ $startAdminServer == "yes" ]] || [[ $startAdminServer == "y" ]]
then
    chmod +x LaunchAdminServer.sh
    ./LaunchAdminServer.sh $hostedZoneId $keyPair
fi


# Create Utility Server

printf "Do you want to instantiate an utility.karan.com server (yes/no): "
read startUtilityServer
if [[ $startUtilityServer == "yes" ]] || [[ $startUtilityServer == "y" ]]
then
    chmod +x LaunchUtilityServer.sh
    ./LaunchUtilityServer.sh $hostedZoneId $keyPair
fi


# Create Staging Server

printf "Do you want to instantiate an staging.karan.com server (yes/no): "
read startStagingServer
if [[ $startStagingServer == "yes" ]] || [[ $startStagingServer == "y" ]]
then
    chmod +x LaunchStagingServer.sh
    ./LaunchStagingServer.sh $hostedZoneId $keyPair
fi

#
# Create karan wX servers template Server

printf "Do you want to create karan wX servers template (yes/no): "
read startWxServer
if [[ $startWxServer == "yes" ]] || [[ $startWxServer == "y" ]]
then
    printf "Enter Launch Template Name to be created for karan wX servers (example: karan) : "
    read templateName

    chmod +x createkaranServerTemplate.sh
    ./createkaranServerTemplate.sh $templateName
fi

#
# Create start Load Balancer Auto Scaling Server

printf "Do you want to create load balancer and autoscaling group template (yes/no): "
read startLoadBalancerAutoScaling
if [[ $startLoadBalancerAutoScaling == "yes" ]] || [[ $startLoadBalancerAutoScaling == "y" ]]
then
    chmod +x launchLoadBalancerAutoScaling.sh
    ./launchLoadBalancerAutoScaling.sh $vpcId $templateName
fi

#
# Remove bootstrap from security groups

printf "Do you want to remove bootstrap from all security groups rules (yes/no): "
read removeBootstrapFromSecurityGroups
if [[ $removeBootstrapFromSecurityGroups == "yes" ]] || [[ $removeBootstrapFromSecurityGroups == "y" ]]; then
    ./removeBootstrapFromSecurityGroups.sh
    printf "Security Group rules updated\n"
fi