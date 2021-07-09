#!/bin/sh
SECURITY_GROUP_NAME=$1
TYPE=$2
PROTOCOL=$3
PORT=$4
CIDR=$5
DESCRIPTION=$6


if [[ $SECURITY_GROUP_NAME == "" ]] || [[ $PROTOCOL == "" ]] || [[ $PORT == "" ]] || [[ $CIDR == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: securityGroupRuleDelete.sh [SECURITY_GROUP_NAME] [PROTOCOL] [PORT] [CIDR], missing param(s)\n\n"
    exit 2
fi

#
# Get security group Id

currDir=$(dirname "$0")
securityGroupId=$($currDir/securityGroupGetId.sh $SECURITY_GROUP_NAME)

if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The Security group name: $SECURITY_GROUP_NAME was not found\n\n"
    exit 1
fi

printf "Removing security group $TYPE rule for: $SECURITY_GROUP_NAME - Port: $PORT, CIDR:$CIDR... "

aws ec2 revoke-security-group-$TYPE \
    --group-id $securityGroupId \
    --protocol $PROTOCOL \
    --port $PORT \
    --cidr $CIDR


#
# Check if rule exists

if [[ $TYPE == "ingress" ]]; then
    checkRule=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    Name=ip-permission.from-port,Values=$PORT \
    Name=ip-permission.to-port,Values=$PORT \
    Name=ip-permission.protocol,Values=$PROTOCOL \
    Name=ip-permission.cidr,Values=\'$CIDR\' \
    --query "SecurityGroups[*].{Name:GroupName}")
else
    checkRule=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    Name=egress.ip-permission.protocol,Values=$PROTOCOL \
    Name=egress.ip-permission.cidr,Values=\'$CIDR\' \
    --query "SecurityGroups[*].{Name:GroupName}")
fi

if [[ $checkRule != [] ]]; then
    printf "\nFATAL ERROR: Rule could not be removed\n\n"
    exit 1
fi

printf "OK\n"
exit 0