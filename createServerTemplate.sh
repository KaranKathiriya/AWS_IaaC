#!/bin/sh

TEMPLATE_NAME=$1

#
# Template Name
if [[ $TEMPLATE_NAME == "" ]]
then
    printf "\nFATAL EXCEPTION: Template Name not entered\n\n"
    exit 1
fi
sed -i "s!{TEMPLATE_NAME}!$TEMPLATE_NAME!g" generated/finished/karan_launch_template.yml

# Create karan Server
read -n 1 -s -r -p "Press any key to continue"

printf "\nEnter New Stack Name for karan Server (example: karan-launch-template)"
read stackName

if [[ $stackName == "" ]]
then
    printf "\nFATAL EXCEPTION: Stack Name not entered\n\n"
    exit 1
fi

aws cloudformation create-stack --stack-name $stackName --template-body file://generated/finished/karan_launch_template.yml

# Wait until Stack create is completed
aws cloudformation wait stack-create-complete --stack-name $stackName
