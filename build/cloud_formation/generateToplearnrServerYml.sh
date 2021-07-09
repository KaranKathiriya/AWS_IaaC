#!/bin/sh

KEY_PAIR_NAME=$1


#
# Check key-pair name

if [[ $KEY_PAIR_NAME == "" ]]; then
    printf "FATAL EXCEPTION: Usage - generatekaranServerYml.sh [key-pair name], missing a parameter(s)\n\n";
fi

helpers/keyPairCheck.sh $KEY_PAIR_NAME
if [[ $? != 0 ]]; then
    printf "\nFATAL EXCEPTION: The key-pair name supplied could not be found by the bootstrap server\n\n"
    exit 1
fi

currDir=$(dirname "$0")
outputDir="$currDir/../../generated/intermediate"

cp $currDir/templates/karan_launch_template.tmpl.yml $outputDir/karan_launch_template.yml


#
# Replace YML template variables with values

sed -i "s!{KEY_PAIR_NAME}!$KEY_PAIR_NAME!g" $outputDir/karan_launch_template.yml