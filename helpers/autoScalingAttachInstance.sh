#!/bin/sh

INSTANCE_ID=$1
AUTOSCALING_GROUP_NAME=$2

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

if [[ $AUTOSCALING_GROUP_NAME == "" ]]
then
    printf "AUTOSCALING GROUP NAME is empty, please enter now: "
    read AUTOSCALING_GROUP_NAME

    if [[ $AUTOSCALING_GROUP_NAME == "" ]]
    then
        printf "\NFATAL EXCEPTION: AUTOSCALING GROUP NAME is empty\n\n"
        exit
    fi
fi


aws autoscaling attach-instances \
--instance-ids $INSTANCE_ID \
--auto-scaling-group-name $AUTOSCALING_GROUP_NAME

exit 0