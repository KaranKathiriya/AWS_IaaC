#!/bin/sh

printf "List of key-pair names (please check on console):\n"
echo $(aws ec2 describe-key-pairs)
exit 0