#!/bin/sh

#
# Configure AWS CLI commands with credentials

printf "\nStep 1/2: Yum installs\n\n"
printf "Do you want to run yum install and git commands (yes/no): "
read setupYum
if [[ $setupYum == "yes" ]] || [[ $setupYum == "y" ]]; then
    sudo yum install aws-cli -y
    sudo mkdir ~/.aws
    sudo yum install git -y
    sudo yum install -y amazon-linux-extras
    sudo yum install mysql -y
    sudo yum install gcc gcc-c++ make -y
    sudo yum install jq -y
    wget http://download.redis.io/redis-stable.tar.gz
    tar xvzf redis-stable.tar.gz 
    cd redis-stable && make
    sudo cp src/redis-cli /usr/bin/ && cd /
    sudo rm -rf redis-stable*
    sudo mkdir /install
    cd /install
    sudo git clone https://gitlab.com/karankathiriya/aws_netops.git
    printf "\n yum install complete, please check if any errors occurred above before continuing (press enter to continue): ";
    read pressEnter
fi

#
# Save AWS credential and config File

printf "\nStep 2/2: Aws configuration\n\n"

printf "Do you want to setup AWS Credentials (yes/no): "
read setupAwsCredentials

printf "Changing directory to: /install/aws_netops/bootstrap"
cd /install/aws_netops
if [[ $setupAwsCredentials == "yes" ]] || [[ $setupAwsCredentials == "y" ]]; then
    printf "Enter AWS Access Key: "
    read AWS_ACCESS_KEY

    printf "Enter AWS Secret Access Key: "
    read AWS_SECRET_ACCESS_KEY

    printf "Enter AWS Region: "
    read AWS_REGION

    printf "Trying to save aws configuration...\n"
    helpers/awsConfigSave.sh $AWS_ACCESS_KEY $AWS_SECRET_ACCESS_KEY $AWS_REGION

    if [[ $? != 0 ]]; then
      printf "\nFATAL EXCEPTION: There was an error creating your AWS credentials\n\n"
      exit 1
    fi
    printf "Save aws configuration success!\n"
fi
