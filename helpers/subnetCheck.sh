#!/bin/sh

SUBNET_ID=$1

if [[ $SUBNET_ID == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: subnetCheck.sh [SUBNET_ID], missing SUBNET_ID\n\n"
    exit 2
fi 

printf "Checking subnet-id name: $SUBNET_ID ... "
subnetInfo=$(aws ec2 describe-subnets --subnet-ids $SUBNET_ID)

if [[ $subnetInfo == "" ]]; then
    printf "\nsubnet-id: $SUBNET_ID not found, exit 1\n\n"
    exit 1
fi

printf "subnet-id found - \n$SUBNET_ID\n"
exit 0