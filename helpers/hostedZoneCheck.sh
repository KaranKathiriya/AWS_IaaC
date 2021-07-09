#!/bin/sh

HOSTED_ZONE_ID=$1

if [[ $HOSTED_ZONE_ID == "" ]]
then
    printf "\nFATAL EXCEPTION - Usage: hostedZoneCheck.sh [HOSTED_ZONE_ID], missing HOSTED_ZONE_ID\n\n"
    exit 2
fi

printf "Checking hosted zone id: $HOSTED_ZONE_ID ..."
hostedZoneInfo=$(aws route53 get-hosted-zone --id $HOSTED_ZONE_ID)

if [[ $hostedZoneInfo == "" ]]
then
    printf "hosted zone id: $HOSTED_ZONE_ID not found, exit 1\n"
    exit 1
fi

printf "hosted zone id: [$HOSTED_ZONE_ID] found\n"
exit 0

 