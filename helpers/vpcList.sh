#!/bin/sh

printf "List of VPCs (please check on console): "
printf "$(aws ec2 describe-vpcs)"
exit 0