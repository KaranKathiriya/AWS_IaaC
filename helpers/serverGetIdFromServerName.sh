#!/bin/sh

SERVER_NAME=$1

#
# Fetching instance id

instance_detail=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$SERVER_NAME" --query 'Reservations[*].Instances[*].InstanceId')
instance_id=$(jq '.[]' <<< "$instance_detail")
instance_id=$(jq '.[]' <<< "$instance_id")

# Here, remove the quotes surrounding the id
instance_id="${instance_id#\"}"
instance_id="${instance_id%\"}"

echo $instance_id
exit 0