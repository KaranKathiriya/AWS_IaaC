#!/bin/sh

INSTANCE_ID=$1
TARGET_GROUP_ARN=$2

if [[ $INSTANCE_ID == "" ]]
then
    printf "INSTANCE ID is empty, please enter now: "
    read INSTANCE_ID

    if [[ $INSTANCE_ID == "" ]]
    then
        printf "\NFATAL EXCEPTION: INSTANCE ID is empty\n\n"
        exit
    fi
fi

if [[ $TARGET_GROUP_ARN == "" ]]
then
    printf "TARGET GROUP ARN is empty, please enter now: "
    read TARGET_GROUP_ARN

    if [[ $TARGET_GROUP_ARN == "" ]]
    then
        printf "\NFATAL EXCEPTION: AUTOSCALING GROUP NAME is empty\n\n"
        exit
    fi
fi

aws elbv2 register-targets \
--target-group-arn $TARGET_GROUP_ARN \
--targets \
--targets Id=$INSTANCE_ID

exit 0