#!/bin/sh

AWS_ACCESS_KEY=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_REGION=$3

# Setup aws credentials in user data

if [[ $AWS_ACCESS_KEY == "" ]] || [[ $AWS_SECRET_ACCESS_KEY == "" ]] || [[ $AWS_REGION == "" ]]; then
    printf "\nFATAL EXCEPTION: Usage error - setupBoostrapServer.sh [aws access key] [aws secret access key] [aws region] [key-pair name], aws data is missing\n\n"
    exit 1
fi

currDir=$(dirname "$0")

cp $currDir/shared_partials/base.partial.sh $currDir/../../generated/intermediate/admin_userdata.sh
cat $currDir/shared_partials/aws.partial.sh >> $currDir/../../generated/intermediate/admin_userdata.sh
cat $currDir/shared_partials/git.partial.sh >> $currDir/../../generated/intermediate/admin_userdata.sh
cat $currDir/shared_partials/yum_node.partial.sh >> $currDir/../../generated/intermediate/admin_userdata.sh
cat $currDir/server_partials/admin.partial.sh >> $currDir/../../generated/intermediate/admin_userdata.sh


sed -i "s!{AWS_CREDENTIALS.AWS_ACCESS_KEY}!$AWS_ACCESS_KEY!g" $currDir/../../generated/intermediate/admin_userdata.sh
sed -i "s!{AWS_CREDENTIALS.AWS_SECRET_ACCESS_KEY}!$AWS_SECRET_ACCESS_KEY!g" $currDir/../../generated/intermediate/admin_userdata.sh
sed -i "s!{AWS_CREDENTIALS.AWS_REGION}!$AWS_REGION!g" $currDir/../../generated/intermediate/admin_userdata.sh
