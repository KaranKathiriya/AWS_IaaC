#!/bin/sh

AWS_ACCESS_KEY=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_REGION=$3

if [[ $AWS_ACCESS_KEY == "" ]] || [[ $AWS_SECRET_ACCESS_KEY == "" ]] || [[ $AWS_REGION == "" ]]; then
    printf "Usage error: setupBoostrapServer.sh [aws access key] [aws secret access key] [aws region]\n"
    printf "Please supply correct number of arguments - Skipping AWS credentials and config creation\n"
    exit 1
fi

printf "[default]\naws_access_key_id=$AWS_ACCESS_KEY\naws_secret_access_key=$AWS_SECRET_ACCESS_KEY\n" > ~/.aws/credentials
printf "[default]\nregion=$AWS_REGION\noutput=json\n" > ~/.aws/config

printf "Completed Boostrap server AWS configuration\n\n"
exit 0