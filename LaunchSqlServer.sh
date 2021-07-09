#!/bin/sh

VPC_ID=$1

if [[ $VPC_ID == "" ]]
then
    printf "VPC ID is empty, please enter now: "
    read VPC_ID

    if [[ $VPC_ID == "" ]]
    then
        printf "\NFATAL EXCEPTION: VPC is empty\n\n"
        exit
    fi
fi

# Getting necessary details for SQL server
printf "Do you want to use Default SQL Details? (yes/no):\n\n"
read get_sql
if [[ $get_sql == "yes" ]] || [[ $get_sql == "y" ]]; then
    db_identifier=karan-mariadb
    db_instance_class=db.t2.micro
    db_engine=MariaDB
    db_storage=20
    db_engine_version=10.2.21
    db_option_group_name=default:mariadb-10-2
    db_availability_zone=us-east-1f
else
    printf "Type the Database Instance Details : "
    printf "DB instance Identifier ( i.e. - karan ) : "
    read db_identifier
    printf "DB instance class ( i.e. - db.t2.micro ) : "
    read db_instance_class
    printf "DB Engine ( i.e. - MariaDB ) : "
    read db_engine
    printf "DB Allocate Storage ( i.e. - 20 ) : "
    read db_storage
    printf "DB Engine Version ( i.e. - 10.2.21 ) : "
    read db_engine_version
    printf "DB Option Group Name ( i.e. - default:mariadb-10-2 ) : "
    read db_option_group_name
    printf "DB Availability Zone ( i.e. - us-east-1f ) : "
    read db_availability_zone
fi

printf "DB Master USername ( i.e. - karan ) : "
read db_uname
printf "DB Master password ( i.e. - asdfasdf ) : "
read db_pass


######################################################
###       Create Security Group For SQL Server     ###
######################################################

printf "Enter Security Group Name for SQL server: "
read securityGroupName

if [[ $securityGroupName == "" ]]
then
    printf "\nFATAL EXCEPTION: Security group cannot be empty\n\n"
    exit 1
fi

helpers/securityGroupCheck.sh $securityGroupName
checkExitCode=$?

# Check had a fatal error, probably empty security group name
if [[ $checkExitCode == 2 ]]; then
    printf "Security Group check had a fatal error (empty security group name?), exiting\n"
    exit 2

# Check didn't find security group name
elif [[ $checkExitCode == 1 ]]; then

    printf "Security Group doesn't exist, do you want to create it?"
    read createSecurityGroup

    if [[ $createSecurityGroup == "yes" ]] || [[ $createSecurityGroup == "y" ]]; then

        printf "Are you sure you want to use the security group name $securityGroupName (yes/no)?"
        read areYouSure
        if [[ $areYouSure == "yes" ]] || [[ $areYouSure == "y" ]]; then
            printf "Creating security group\n"
            security_group=$(helpers/securityGroupCreate.sh $securityGroupName "SQL Server Security Group" $VPC_ID)
        else
            printf "\nFATAL EXCEPTION: User exited script\n\n"
            exit 1
        fi
    else
        printf "\nFATAL EXCEPTION: When launching a new SQL server, you must supply a security group name to attach the server to\n\n"
        exit 1
    fi

elif [[ $checkExitCode == 0 ]]; then
    printf "Security Group exists, do you want to use it?"
    read areYouSure

    if [[ $areYouSure == "no" ]] || [[ $areYouSure == "n" ]]; then
        printf "\nFATAL EXCEPTION: You rejected using the existing security group, please run the script again\n\n"
        exit 1
    fi

else
    printf "\nFATAL EXCEPTION: Unknown exit code for security group check (should never get here)\n\n"
    exit 1
fi

security_group_id=$(helpers/securityGroupGetId.sh $securityGroupName)

printf "SQL Security Group: $securityGroupName has id: $security_group_id\n"

###########################################
###       Authorize Security Group      ###
###########################################


printf "Adding security groups [bootstrap-server] to sql [security group]\n"


private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)/32
helpers/securityGroupRuleAddIp.sh karan-sql ingress tcp 22 $private_ip 'bootstrap-server'
#
# Revoking default egress rule

printf "Revoking security group rule egress [All] to sql [security group]\n"
aws ec2 revoke-security-group-egress \
    --group-id $security_group_id \
    --protocol all \
    --port all \
    --cidr 0.0.0.0/0


####################################
###       Launch SQL Server      ###
####################################


aws rds create-db-instance \
    --db-instance-identifier $db_identifier \
    --db-instance-class $db_instance_class \
    --engine $db_engine \
    --master-username $db_uname \
    --master-user-password $db_pass \
    --allocated-storage $db_storage \
    --engine-version $db_engine_version \
    --option-group-name $db_option_group_name \
    --vpc-security-group-ids $security_group_id \
    --no-publicly-accessible \
    --availability-zone $db_availability_zone \
    --no-enable-iam-database-authentication


######################################
###       Populating Database      ###
######################################


printf "Populate Database (yes/no): "
read populateDB

if [[ $populateDB == "yes" ]] || [[ $populateDB == "y" ]]
then
    printf "\nPopulating database....\n"
    printf "Sorry this is confidential\n"
fi