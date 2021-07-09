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

# Getting necessary details for redis server
#

printf "Do you want to use Default Redis Cluster's Details? (yes/no): "
read get_redis
if [[ $get_redis == "yes" ]] || [[ $get_redis == "y" ]]; then
    redis_cluster_id="karan-redis"
    redis_cluster_node="cache.t2.micro"
    redis_engine_version="5.0.6"
    redis_cache_nodes="1"
    redis_parameter_group="default.redis5.0"
else
    printf "Enter the Redis Cluster's Details:\n\n"
    printf "redis cluster name (default: karan-redis): "
    read redis_cluster_id
    printf "redis cluster node type (default: cache.t2.micro): "
    read redis_cluster_node
    printf "redis Engine Version (default: 6.x): "
    read redis_engine_version
    printf "redis number of cache nodes (default: 2): "
    read redis_cache_nodes
    printf "redis Parameter Group (default: default.redis6.x): "
    read redis_parameter_group
fi



########################################################
###       Create Security Group For Redis Server     ###
########################################################

printf "Enter Security Group Name for redis server: "
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
            security_group=$(helpers/securityGroupCreate.sh $securityGroupName "Redis Server Security Group" $VPC_ID)
        else
            printf "\nFATAL EXCEPTION: User exited script\n\n"
            exit 1
        fi
    else
        printf "\nFATAL EXCEPTION: When launching a new redis server, you must supply a security group name to attach the server to\n\n"
        exit 1
    fi

elif [[ $checkExitCode == 0 ]]; then
    printf "\nSecurity Group exists, are you want to use it?"
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

printf "Redis Security Group: $securityGroupName has id: $security_group_id\n"

###########################################
###       Authorize Security Group      ###
###########################################

printf "Adding security groups [bootstrap-server] to sql [security group]\n"

public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)/32
helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 22 $public_ip 'bootstrap-server'

######################################
###       Launch Redis Server      ###
######################################

printf "Trying to create redis server...";
aws elasticache create-cache-cluster \
--cache-cluster-id $redis_cluster_id \
--cache-node-type $redis_cluster_node \
--engine redis \
--engine-version $redis_engine_version \
--num-cache-nodes $redis_cache_nodes \
--cache-parameter-group $redis_parameter_group \
--security-group-ids $security_group_id

printf " command complete, check with console/cli if server is running\n";