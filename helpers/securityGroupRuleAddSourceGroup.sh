#!/bin/sh
SECURITY_GROUP_NAME=$1
TYPE=$2
PROTOCOL=$3
PORT=$4
SOURCE_GROUP=$5

if [[ $SECURITY_GROUP_NAME == "" ]] || [[ $PROTOCOL == "" ]] || [[ $PORT == "" ]] || [[ $SOURCE_GROUP == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: securityGroupRuleAdd.sh [SECURITY_GROUP_NAME] [PROTOCOL] [PORT] [SOURCE_GROUP], missing param(s)\n\n"
    exit 2
fi

#
# Get security group Id

currDir=$(dirname "$0")
securityGroupId=$($currDir/securityGroupGetId.sh $SECURITY_GROUP_NAME)
sourceGroupId=$($currDir/securityGroupGetId.sh $SOURCE_GROUP)

if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The Security group name: $SECURITY_GROUP_NAME was not found\n\n"
    exit 1
fi

printf "Adding security group $TYPE rule for: $SECURITY_GROUP_NAME - Port: $PORT, SOURCE_GROUP:$SOURCE_GROUP... "

aws ec2 authorize-security-group-$TYPE \
    --group-id $securityGroupId \
    --protocol $PROTOCOL \
    --port $PORT \
    --source-group $sourceGroupId

#
# Check if rule exists

if [[ $TYPE == "ingress" ]]; then
    checkRule=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    Name=ip-permission.from-port,Values=$PORT \
    Name=ip-permission.to-port,Values=$PORT \
    Name=ip-permission.protocol,Values=$PROTOCOL \
    Name=ip-permission.group-id,Values=$sourceGroupId \
    --query "SecurityGroups[*].{Name:GroupName}")
else
    checkRule=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    Name=egress.ip-permission.protocol,Values=$PROTOCOL \
    Name=egress.ip-permission.group-id,Values=$sourceGroupId \
    --query "SecurityGroups[*].{Name:GroupName}")
fi

if [[ $checkRule == [] ]]; then
    printf "\nFATAL ERROR: Added rule could not be found\n\n"
    exit 1
fi


printf "OK\n"
exit 0
