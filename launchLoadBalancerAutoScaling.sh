#!/bin/sh

VPC_ID=$1
TEMPLATE_NAME=$2

if [[ $VPC_ID == "" ]]
then
    printf "\nVPC ID is empty, please enter now: \n"
    read VPC_ID

    if [[ $VPC_ID == "" ]]; then
        printf "\nFATAL EXCEPTION: VPC ID not entered\n"
        exit 1
    fi
fi

if [[ $TEMPLATE_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Template Name not entered\n"
    printf "\nEnter Correct Number of ARGUMENTS\n\n"
    exit 1
fi

printf "\nEnter Existing Security Group Name to be attached (example: karan) : \n"
read securityGroupName

if [[ $securityGroupName == "" ]]
then
    printf "\nFATAL EXCEPTION: Security Group Name not entered\n\n"
    exit 1
fi

#
# Wait Until Security Group is created
#

wait_for_running=null
while [[ $wait_for_running == null ]]
do
    wait_for_running=$(aws ec2 describe-security-groups \
    --group-names $securityGroupName \
    --query 'SecurityGroups[0].GroupId')
    printf "."
    sleep 5s
done


###################################################
###       Editing Rules for Security Group      ###
###################################################

security_group=$(aws ec2 describe-security-groups \
--group-names $securityGroupName)

security_group_id=$(jq '.SecurityGroups[].GroupId' <<< "$security_group")
security_group_id="${security_group_id#\"}"
security_group_id="${security_group_id%\"}"

#
# Allowing HTTPS from anywhere
#

authorize=$(aws ec2 authorize-security-group-ingress \
--group-name $securityGroupName \
--protocol tcp \
--port 443 \
--cidr 0.0.0.0/0)

printf "$authorize\n"


###################################################
###       Create Application Load Balancer      ###
###################################################

printf "\nEnter Load Balancer Name (NEW) (eg: karan-load-balancer)\n"
read load_balancer_name

if [[ $load_balancer_name == "" ]]
then
    printf "\nFATAL EXCEPTION: Load Balancer Name not entered\n"
    exit 1
fi

printf "Subnet Id accessible by this bootstrap server:\n"
helpers/subnetList.sh

printf "\nEnter Subnet Id 1 for Load Balancer (eg: subnet-xxxxxxxx)\n"
read subnet_1

helpers/subnetCheck.sh $subnet_1
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The subnet-id name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi
printf "subnet-id [$subnet_1] is valid, continuing with next step\n\n"

printf "\nEnter Subnet Id 2 for Load Balancer (eg: subnet-xxxxxxxx)\n"
read subnet_2

helpers/subnetCheck.sh $subnet_2
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The subnet-id name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi
printf "subnet-id [$subnet_2] is valid, continuing with next step\n\n"

if [[ $subnet_1 == "" ]] || [[ $subnet_2 == "" ]]
then
    printf "\nFATAL EXCEPTION: Subnets not entered\n"
    exit 1
fi

load_balancer=$(aws elbv2 create-load-balancer \
--name $load_balancer_name \
--subnets $subnet_1 $subnet_2 \
--security-groups "$security_group_id")

printf "$load_balancer\n"


###################################################
###             Create Target Group             ###
###################################################


printf "\nEnter Target Group Name (NEW) for load balancer (eg: karan-target-group)\n"
read target_group_name     # Default Security Group Name

if [[ $target_group_name == "" ]]
then
    printf "\nFATAL EXCEPTION: Target Group Name not entered\n"
    exit
fi


target_group=$(aws elbv2 create-target-group \
--name $target_group_name \
--protocol HTTP \
--port 80 \
--vpc-id $VPC_ID)

printf "$target_group\n"


#####################################################################
###   Create Listener to attach Target Group with Load Balancer   ###
#####################################################################

loadbalancer_arn=$(jq '.LoadBalancers[].LoadBalancerArn' <<< "$load_balancer")
loadbalancer_arn="${loadbalancer_arn%\"}"
loadbalancer_arn="${loadbalancer_arn#\"}"

target_group_arn=$(jq '.TargetGroups[].TargetGroupArn' <<< "$target_group")
target_group_arn="${target_group_arn%\"}"
target_group_arn="${target_group_arn#\"}"

aws elbv2 create-listener --load-balancer-arn $loadbalancer_arn \
--protocol HTTPS \
--port 443 \
--default-actions Type=forward,TargetGroupArn=$target_group_arn


###################################################
###           Create Autoscaling Group          ###
###################################################

printf "\nEnter Autoscaling Group Name (NEW) for load balancer (eg: karan-autoscaling)\n"
read autoscaling_name     # Default Security Group Name

if [[ $autoscaling_name == "" ]]
then
    printf "\nFATAL EXCEPTION: Auto Scaling Group Name not entered\n"
    exit
fi

autoscaling=$(aws autoscaling create-auto-scaling-group \
--auto-scaling-group-name $autoscaling_name \
--launch-template "LaunchTemplateName=$TEMPLATE_NAME,Version=1" \
--min-size 1 \
--max-size 3 \
--desired-capacity 1 \
--vpc-zone-identifier "$subnet_1,$subnet_2" \
--target-group-arns "$target_group_arn" )