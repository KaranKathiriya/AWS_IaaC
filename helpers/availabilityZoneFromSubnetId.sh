#!/bin/sh

SUBNET_ID=$1

if [[ $SUBNET_ID == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: availabilityZoneFromSubnetId.sh [SUBNET_ID], missing SUBNET_ID\n\n"
    exit 2
fi

subnet_info=$(aws ec2 describe-subnets --subnet-ids $SUBNET_ID)
availability_zone=$(jq '.Subnets[].AvailabilityZone' <<< "$subnet_info")


# Here, remove the quotes surrounding the id
availability_zone="${availability_zone#\"}"
availability_zone="${availability_zone%\"}"

echo $availability_zone
exit 0