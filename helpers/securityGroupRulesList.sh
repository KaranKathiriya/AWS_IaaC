#!/bin/sh

#
# log-servers security group rules
printf "\nlog-servers security group INGRESS rule\n\n"
aws ec2 describe-security-groups --group-names log-servers --query "SecurityGroups[*].IpPermissions"
printf "\nlog-servers security group EGRESS rule\n\n"
aws ec2 describe-security-groups --group-names log-servers --query "SecurityGroups[*].IpPermissionsEgress"

#
# admin-servers security group rules
printf "\nadmin-servers security group INGRESS rule\n\n"
aws ec2 describe-security-groups --group-names admin-servers --query "SecurityGroups[*].IpPermissions"
printf "\nadmin-servers security group EGRESS rule\\n"
aws ec2 describe-security-groups --group-names admin-servers --query "SecurityGroups[*].IpPermissionsEgress"

#
# utility-servers security group rules
printf "\nutility-servers security group INGRESS rule\n\n"
aws ec2 describe-security-groups --group-names utility-servers --query "SecurityGroups[*].IpPermissions"
printf "\nutility-servers security group EGRESS rule\n\n"
aws ec2 describe-security-groups --group-names utility-servers --query "SecurityGroups[*].IpPermissionsEgress"

#
# karan-servers security group rules
printf "\nkaran-servers security group INGRESS rule\n\n"
aws ec2 describe-security-groups --group-names karan-servers --query "SecurityGroups[*].IpPermissions"
printf "\nkaran-servers security group EGRESS rule\n\n"
aws ec2 describe-security-groups --group-names karan-servers --query "SecurityGroups[*].IpPermissionsEgress"