#!/bin/sh
SECURITY_GROUP_NAME=$1
TYPE=$2
PROTOCOL=$3
FROM_PORT=$4
TO_PORT=$5
IPV6_RANGES=$6

# TODO - add description into the query directy
# SEE: https://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-egress.html
#      https://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html
DESCRIPTION=$7



if [[ $SECURITY_GROUP_NAME == "" ]] || [[ $TYPE == "" ]] || [[ $PROTOCOL == "" ]] || [[ $FROM_PORT == "" ]] || [[ $TO_PORT == "" ]] || [[ $IPV6_RANGES == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: securityGroupRuleAddIpV6.sh - missing param(s)\n\n"
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

printf "Adding security group $TYPE rule for: $SECURITY_GROUP_NAME - FromPort: $FROM_PORT, ToPort: $TO_PORT, Ipv6Ranges:$IPV6_RANGES... "

aws ec2 authorize-security-group-$TYPE \
    --group-id $securityGroupId \
    --ip-permissions IpProtocol=$PROTOCOL,FromPort=$FROM_PORT,ToPort=$TO_PORT,Ipv6Ranges='[{CidrIpv6='$IPV6_RANGES'}]'

#
# Check if rule exists

if [[ $TYPE == "ingress" ]]; then
    checkRule=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    Name=ip-permission.from-port,Values=$FROM_PORT \
    Name=ip-permission.to-port,Values=$TO_PORT \
    Name=ip-permission.protocol,Values=$PROTOCOL \
    Name=ip-permission.ipv6-cidr,Values=$IPV6_RANGES \
    --query "SecurityGroups[*].{Name:GroupName}")
else
    checkRule=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    Name=egress.ip-permission.protocol,Values=$PROTOCOL \
    Name=egress.ip-permission.cidr,Values=$IPV6_RANGES \
    --query "SecurityGroups[*].{Name:GroupName}")
fi

if [[ $checkRule == [] ]]; then
    printf "\nFATAL ERROR: Added rule could not be found\n\n"
    exit 1
fi

printf "OK\n"
exit 0
