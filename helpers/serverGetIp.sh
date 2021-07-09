#!/bin/sh

INSTANCE_ID=$1

#
# Fetching instance details

instance_details=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID)
public_ip=$(jq '.Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp'<<<"$instance_details")


# Here, remove the quotes surrounding the ip
public_ip="${public_ip#\"}"
public_ip="${public_ip%\"}"


echo $public_ip
exit 0