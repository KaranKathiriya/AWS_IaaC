#!/bin/sh
KEY_PAIR_NAME=$1
AWS_AVAILABILITY_ZONE=$2


#
# Check key-pair name

if [[ $KEY_PAIR_NAME == "" ]] || [[ $AWS_AVAILABILITY_ZONE == "" ]]; then
    printf "FATAL EXCEPTION: Usage - generateLogServerYml.sh [key-pair name], missing a parameter(s)\n\n";
fi

helpers/keyPairCheck.sh $KEY_PAIR_NAME
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The key-pair name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi


currDir=$(dirname "$0")
outputDir="$currDir/../../generated/intermediate"

cp $currDir/templates/adminserver_cloudformation.tmpl.yml $outputDir/adminserver_cloudformation.yml


#
# Replace YML template variables with values

sed -i "s!{KEY_PAIR_NAME}!$KEY_PAIR_NAME!g" $outputDir/adminserver_cloudformation.yml
sed -i "s!{AWS_AVAILABILITY_ZONE}!$AWS_AVAILABILITY_ZONE!g" $outputDir/adminserver_cloudformation.yml