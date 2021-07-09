#!/bin/sh

VPC_ID=$1

if [[ $VPC_ID == "" ]]
then
    printf "\nFATAL EXCEPTION - Usage: vpcCheck.sh [VPC_ID], missing VPC_ID\n\n"
    exit 1
fi

printf "Checking vpc-id: $VPC_ID ..."
vpcInfo=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID)

if [[ $vpcInfo == "" ]]
then
    printf "vpc-id: $VPC_ID not found, exit 1\n"
    exit 1
fi

printf "vpc-id: [$VPC_ID] found\n"
exit 0