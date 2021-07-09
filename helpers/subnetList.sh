#!/bin/sh

printf "List of key-pair names (please check on console):\n"
echo $(aws ec2 describe-subnets \
--query "Subnets[*].{AvailabilityZone:AvailabilityZone,SubnetId:SubnetId}")
exit 0