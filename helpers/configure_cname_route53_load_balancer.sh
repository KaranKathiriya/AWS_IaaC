#!/bin/sh
HOSTED_ZONE_ID=$1
LOAD_BALANCER_NAME=$2

cName="api.karan.com"

alb_details=$(aws elbv2 describe-load-balancers --names $LOAD_BALANCER_NAME)

alb_dns=$(jq '.LoadBalancers[].DNSName' <<< $alb_details)
alb_dns="${alb_dns%\"}"
alb_dns="${alb_dns#\"}"
alb_hosted_id=$(jq '.LoadBalancers[].CanonicalHostedZoneId' <<< $alb_details)
alb_hosted_id="${alb_hosted_id%\"}"
alb_hosted_id="${alb_hosted_id#\"}"

printf "{\n\"Comment\": \"CREATE/DELETE/UPSERT a record \",\n\"Changes\": [{\n\"Action\": \"UPSERT\",\n\"ResourceRecordSet\": {\n\"Name\": \"$cName\",\n\"Type\": \"A\",\n\"AliasTarget\":{\n\"DNSName\": \"$alb_dns\",\n\"HostedZoneId\": \"$alb_hosted_id\",\n\"EvaluateTargetHealth\": false}}\n}]\n}" > ~/cname-conf-route53
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://~/cname-conf-route53