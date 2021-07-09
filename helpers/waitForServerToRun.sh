#!/bin/sh

SERVER_NAME=$1

wait_for_running=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$SERVER_NAME" \
--query 'Reservations[0].Instances[0].State.Name')

while [[ $wait_for_running != "\"running\"" ]]
do
    wait_for_running=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$SERVER_NAME" \
    --query 'Reservations[0].Instances[0].State.Name')
    printf "."
    sleep 10s
done