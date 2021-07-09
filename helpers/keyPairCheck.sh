#!/bin/sh

KEY_PAIR_NAME=$1

if [[ $KEY_PAIR_NAME == "" ]]; then
    printf "\nFATAL EXCEPTION - Usage: keyPairCheck.sh [KEY_PAIR_NAME], missing KEY_PAIR_NAME\n\n"
    exit 2
fi 

printf "Checking key-pair name: $KEY_PAIR_NAME ... "
keyPairInfo=$(aws ec2 describe-key-pairs --key-names $KEY_PAIR_NAME)

if [[ $keyPairInfo == "" ]]; then
    printf "\nkey-pair: $KEY_PAIR_NAME not found, exit 1\n\n"
    exit 1
fi

printf "key-pair found - \n$keyPairInfo\n"
exit 0