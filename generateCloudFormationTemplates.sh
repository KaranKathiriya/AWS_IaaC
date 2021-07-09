#!/bin/sh

AWS_ACCESS_KEY=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_REGION=$3

VPC_ID=$4
HOSTED_ZONE_ID=$5
KEY_PAIR_NAME=$6
AWS_AVAILABILITY_ZONE=$7


#
# Created required directories for 

mkdir -p generated/intermediate
mkdir -p generated/finished


#
# Set AWS credentials in CloudFormation scripts usermeta data

if [[ $AWS_ACCESS_KEY == "" ]]; then
    printf "Enter AWS Access Key: "
    read AWS_ACCESS_KEY
fi

if [[ $AWS_SECRET_ACCESS_KEY == "" ]]; then
    printf "Enter AWS Secret Access Key: "
    read AWS_SECRET_ACCESS_KEY
fi

if [[ $AWS_REGION == "" ]]; then
    printf "Enter AWS Region: "
    read AWS_REGION
fi

if [[ $AWS_ACCESS_KEY == "" ]] || [[ $AWS_SECRET_ACCESS_KEY == "" ]] || [[ $AWS_REGION == "" ]]
then
    printf "\nFATAL EXCEPTION - Usage error: setupBoostrapServer.sh [aws access key] [aws secret access key] [aws region] - please supply correct number of arguments\n\n"
    exit 1
fi

#
# Display and choose vpc to use in VPC templates

if [[ $VPC_ID == "" ]]; then
    printf "VPCs accessible by this bootstrap server:\n"
    helpers/vpcList.sh
    printf "Please enter the vpc which you want: "
    read VPC_ID
fi

helpers/vpcCheck.sh $VPC_ID
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The VPC ID supplied could not be found by the bootstrap server\n\n"
    exit 1
fi


#
# Check Key is valid

if [[ $KEY_PAIR_NAME == "" ]]; then
    printf "Key-pair names accessible by this bootstrap server:\n"
    helpers/keyPairList.sh
    printf "Please enter the key-pair you wish to use: "
    read KEY_PAIR_NAME
fi

helpers/keyPairCheck.sh $KEY_PAIR_NAME
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The key-pair name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi


#
# Check availability zone

if [[ $AWS_AVAILABILITY_ZONE == "" ]]; then
    printf "Please enter the availability zone you wish to add your servers to:\n"
    read AWS_AVAILABILITY_ZONE
fi
if [[ $AWS_AVAILABILITY_ZONE == "" ]]; then
    printf "\nFATAL EXCEPTION: The availability zone cannot be empty\n\n"
    exit 1
fi


#
# Log Cloudformation YML

printf "Generating Log CloudFormation yml and userdata files output dir: generated/intermediate/\n"
build/cloud_formation/generateLogServerYml.sh $KEY_PAIR_NAME $AWS_AVAILABILITY_ZONE
build/user_data/generate_log_userdata.sh $AWS_ACCESS_KEY $AWS_SECRET_ACCESS_KEY $AWS_REGION

logserverUserDataBase64=$(cat generated/intermediate/log_userdata.sh | base64 -w 0)

cp generated/intermediate/logserver_cloudformation.yml generated/finished
sed -i "s!{USERDATA}!$logserverUserDataBase64!g" generated/finished/logserver_cloudformation.yml


#
# Admin Cloudformation YML
#

printf "Generating Admin CloudFormation yml and userdata files output dir: generated/intermediate/\n"
build/cloud_formation/generateAdminServerYml.sh $KEY_PAIR_NAME $AWS_AVAILABILITY_ZONE
build/user_data/generate_admin_userdata.sh $AWS_ACCESS_KEY $AWS_SECRET_ACCESS_KEY $AWS_REGION

adminserverUserDataBase64=$(cat generated/intermediate/admin_userdata.sh | base64 -w 0)

cp generated/intermediate/adminserver_cloudformation.yml generated/finished
sed -i "s!{USERDATA}!$adminserverUserDataBase64!g" generated/finished/adminserver_cloudformation.yml


#
# Utility Cloudformation YML
#

printf "Generating Utility CloudFormation yml and userdata files output dir: generated/intermediate/\n"
build/cloud_formation/generateUtilityServerYml.sh $KEY_PAIR_NAME $AWS_AVAILABILITY_ZONE
build/user_data/generate_utility_userdata.sh $AWS_ACCESS_KEY $AWS_SECRET_ACCESS_KEY $AWS_REGION

utilityserverUserDataBase64=$(cat generated/intermediate/utility_userdata.sh | base64 -w 0)

cp generated/intermediate/utilityserver_cloudformation.yml generated/finished
sed -i "s!{USERDATA}!$utilityserverUserDataBase64!g" generated/finished/utilityserver_cloudformation.yml


#
# karan Cloudformation YML
#

printf "Generating karan CloudFormation yml and userdata files output dir: generated/intermediate/\n"
build/cloud_formation/generatekaranServerYml.sh $KEY_PAIR_NAME
build/user_data/generate_karan_userdata.sh $AWS_ACCESS_KEY $AWS_SECRET_ACCESS_KEY $AWS_REGION $HOSTED_ZONE_ID

karanserverUserDataBase64=$(cat generated/intermediate/karan_userdata.sh | base64 -w 0)

cp generated/intermediate/karan_launch_template.yml generated/finished
sed -i "s!{USERDATA}!$karanserverUserDataBase64!g" generated/finished/karan_launch_template.yml

#
# Staging Cloudformation YML
#

printf "Generating Staging CloudFormation yml and userdata files output dir: generated/intermediate/\n"
build/cloud_formation/generateStagingServerYml.sh $KEY_PAIR_NAME $AWS_AVAILABILITY_ZONE
build/user_data/generate_staging_userdata.sh $AWS_ACCESS_KEY $AWS_SECRET_ACCESS_KEY $AWS_REGION

stagingserverUserDataBase64=$(cat generated/intermediate/staging_userdata.sh | base64 -w 0)

cp generated/intermediate/stagingserver_cloudformation.yml generated/finished
sed -i "s!{USERDATA}!$stagingserverUserDataBase64!g" generated/finished/stagingserver_cloudformation.yml
