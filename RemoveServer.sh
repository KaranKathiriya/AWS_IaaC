#!/bin/sh

#
# Server Name

printf "Enter Server Name (example: stagingX.karan.com) : "
read SERVER_NAME

if [[ $SERVER_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Server Name not entered\n\n"
    exit 1
fi

#
# Hosted Zone Id Name

printf "Available hosted zones:\n"
helpers/hostedZoneList.sh

printf "Enter Server Name (example: ZXXXXX) : "
read HOSTED_ZONE_ID

if [[ $HOSTED_ZONE_ID == "" ]]
then
    printf "\nFATAL EXCEPTION: HOSTED_ZONE_ID not entered\n\n"
    exit 1
fi

# Extracting instance_id
instance_id=$(helpers/serverGetIdFromServerName.sh $SERVER_NAME)

# Extracting Stack Name
stack_details=$(aws cloudformation describe-stack-resources --physical-resource-id $instance_id)
stack_name=$(jq '.StackResources[].StackName' <<< "$stack_details")

# Here, remove the quotes surrounding the id
stack_name="${stack_name#\"}"
stack_name="${stack_name%\"}"

aws cloudformation delete-stack --stack-name $stack_name

# Extracting PublicIpAddress
public_ip=$(helpers/serverGetIp.sh $instance_id)

#
# Removing IP form route 53

printf "cname record $SERVER_NAME was added to Route53\n"
printf "{\n\"Comment\": \"CREATE/DELETE/UPSERT a record \",\n\"Changes\": [{\n\"Action\": \"DELETE\",\n\"ResourceRecordSet\": {\n\"Name\": \"$SERVER_NAME\",\n\"Type\": \"A\",\n\"TTL\": 300,\n\"ResourceRecords\": [{ \"Value\": \"$public_ip\"}]\n}}]\n}" > ~/cname-conf-route53
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://~/cname-conf-route53