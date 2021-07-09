#!/bin/sh

SECURITY_GROUP_NAME=$1

if [[ $SECURITY_GROUP_NAME == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: securityGroupGetId.sh [SECURITY_GROUP_NAME], missing SECURITY_GROUP_NAME\n\n"
    exit 2
fi

#
# Fetching security group id

security_group_info=$(aws ec2 describe-security-groups \
--group-names $SECURITY_GROUP_NAME)

if [[ $security_group_info == "" ]]; then
    printf "\nFATAL EXCEPTION: security group: $SECURITY_GROUP_NAME not found, exit 1\n\n"
    exit 1
fi

security_group_id=$(jq '.SecurityGroups[].GroupId' <<< "$security_group_info")

# Here, remove the quotes surrounding the id
security_group_id="${security_group_id#\"}"
security_group_id="${security_group_id%\"}"

echo $security_group_id
exit 0