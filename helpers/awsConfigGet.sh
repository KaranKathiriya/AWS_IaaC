#!/bin/sh

AWS_CREDENTIALS_INI_FILE=~/.aws/credentials
AWS_CONFIG_INI_FILE=~/.aws/config

if [[ ! -f "$AWS_CREDENTIALS_INI_FILE" ]]; then
    printf "/nFATAL EXCEPTION: aws credentials file '$AWS_CREDENTIALS_INI_FILE' does not exist\n\n"
    exit 1
fi

if [[ ! -f "$AWS_CONFIG_INI_FILE" ]]; then
    printf "/nFATAL EXCEPTION: aws credentials file '$AWS_CREDENTIALS_INI_FILE' does not exist\n\n"
	exit 1
fi

while IFS='=' read key value
do
    if [[ $key == \[*] ]]; then
        section=$key
    elif [[ $value ]] && [[ $section == '[default]' ]]; then
        if [[ $key == 'aws_access_key_id' ]]; then
            AWS_ACCESS_KEY_ID=$value
        elif [[ $key == 'aws_secret_access_key' ]]; then
            AWS_SECRET_ACCESS_KEY=$value
        fi
    fi
done < $AWS_CREDENTIALS_INI_FILE

while IFS='=' read key value
do
    if [[ $key == \[*] ]]; then
        section=$key
    elif [[ $value ]] && [[ $section == '[default]' ]]; then
        if [[ $key == 'region' ]]; then
            AWS_REGION=$value
        fi
    fi
done < $AWS_CONFIG_INI_FILE

echo "$AWS_ACCESS_KEY_ID;$AWS_SECRET_ACCESS_KEY;$AWS_REGION"
exit 0