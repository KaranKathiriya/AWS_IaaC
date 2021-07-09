#!/bin/sh

SECURITY_GROUP_NAME=$1

if [[ $SECURITY_GROUP_NAME == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: securityGroupCheck.sh [SECURITY_GROUP_NAME], missing SECURITY_GROUP_NAME\n\n"
    exit 2
fi

printf "Checking security group name: $SECURITY_GROUP_NAME ... "
securityGroupInfo=$(aws ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME)

if [[ $securityGroupInfo == "" ]]; then
    printf "\nsecurity group: $SECURITY_GROUP_NAME not found, exit 1\n\n"
    exit 1
fi

printf "security group found - \n$securityGroupInfo\n"
exit 0