# Using INSTANCE_ID of the ec2 instance
HOSTNAME=$1
IP=$2
HOSTED_ZONE_ID=$3
INSTANCE_ID=$4
SERVER_TAG=$5

printf "Created Tag: Key=Name Value=$HOSTNAME\n"
aws ec2 create-tags --resources $INSTANCE_ID --tag "Key=Name,Value=$HOSTNAME"
aws ec2 create-tags --resources $INSTANCE_ID --tag "Key=server,Value=$SERVER_TAG"


printf "cname record $HOSTNAME was added to Route53\n"
printf "{\n\"Comment\": \"CREATE/DELETE/UPSERT a record \",\n\"Changes\": [{\n\"Action\": \"UPSERT\",\n\"ResourceRecordSet\": {\n\"Name\": \"$HOSTNAME\",\n\"Type\": \"A\",\n\"TTL\": 300,\n\"ResourceRecords\": [{ \"Value\": \"$IP\"}]\n}}]\n}" > ~/cname-conf-route53
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://~/cname-conf-route53