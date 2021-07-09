#!/bin/sh

SERVER_NAME=$1

checkResults=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$SERVER_NAME" \
--query 'Reservations[0].Instances[0].State.Name')

# Here, remove the quotes surrounding the result
checkResults="${checkResults#\"}"
checkResults="${checkResults%\"}"

echo $checkResults
exit 0