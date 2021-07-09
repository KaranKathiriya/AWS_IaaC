GROUP_NAME=$1
DESCRIPTION=$2
VPC_ID=$3

if [[ $GROUP_NAME == "" ]] || [[ $DESCRIPTION == "" ]] || [[ $VPC_ID == "" ]]; then
    printf "\nFATAL ERROR:  - Usage: securityGroupCreate.sh [GROUP_NAME] [DESCRIPTION] [VPC_ID], there is an error in the parameters\n\n"
    exit 1
fi

security_group=$(aws ec2 create-security-group \
--group-name $GROUP_NAME \
--description "$DESCRIPTION" \
--tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value='$GROUP_NAME'}]' \
--vpc-id $VPC_ID)

if [[ $? != 0 ]]; then
    printf "\nFATAL ERROR:  - There was an error creating the security group\n\n"
    exit 1
fi
wait_for_running=null
while [[ $wait_for_running == null ]]
do
    wait_for_running=$(aws ec2 describe-security-groups \
    --filters "Name=tag:Name,Values=$GROUP_NAME" \
    --query 'SecurityGroups[0].GroupId')
    sleep 2s
done

echo $security_group
exit 0