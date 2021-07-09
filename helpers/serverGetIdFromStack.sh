#!/bin/sh

STACK_NAME=$1

#
# Fetching instance id

stack_details=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME)
instance_id=$(jq '.StackResources[].PhysicalResourceId'<<<"$stack_details")

# Here, remove the quotes surrounding the id
instance_id="${instance_id#\"}"
instance_id="${instance_id%\"}"

echo $instance_id
exit 0