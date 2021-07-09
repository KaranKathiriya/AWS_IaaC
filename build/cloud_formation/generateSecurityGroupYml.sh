#!/bin/sh

VPC_ID=$1

if [[ $VPC_ID == "" ]]
then
    printf "Usage: generateSecurityGroupYml.sh [VPC_ID] - please try again\n"
    exit
fi

currDir=$(dirname "$0")
outputDir="$currDir/../../generated/intermediate"

cp $currDir/templates/instantiate_security_groups.tmpl.yml $outputDir/instantiate_security_groups.yml
sed -i "s/{VPC_ID}/$VPC_ID/g" $outputDir/instantiate_security_groups.yml

cp generated/intermediate/instantiate_security_groups.yml generated/finished