#!/bin/sh

public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)/32
helpers/securityGroupRuleAddIp.sh log-servers ingress tcp 22 $public_ip 'bootstrap-server'
helpers/securityGroupRuleAddIp.sh admin-servers ingress tcp 22 $public_ip 'bootstrap-server'
helpers/securityGroupRuleAddIp.sh utility-servers ingress tcp 22 $public_ip 'bootstrap-server'
helpers/securityGroupRuleAddIp.sh karan-servers ingress tcp 22 $public_ip 'bootstrap-server'