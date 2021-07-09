#!/bin/sh

#
# List Existing Security Group Rules

printf "Do you want to List all security group rules (yes/no): "
read securityGroupRulesList
if [[ $securityGroupRulesList == "yes" ]] || [[ $securityGroupRulesList == "y" ]]; then
    helpers/securityGroupRulesList.sh
fi

#
# Add New Security Group Rules

printf "Do you want to add security group rules (yes/no): "
read securityGroupRules
if [[ $securityGroupRules == "yes" ]] || [[ $securityGroupRules == "y" ]]; then

    #
    # Log Servers
    securityGroupName=log-servers

    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 80 0.0.0.0/0 'http-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 80 80 ::/0 'http-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 443 0.0.0.0/0 'https-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 443 443 ::/0 'https-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 3000 0.0.0.0/0 'node-log-server-ingress'
    # EGRESS RULES
    helpers/securityGroupRuleAddIp.sh $securityGroupName egress -1 -1 0.0.0.0/0 'default-egress'

exit 0
    #
    # Admin Servers
    securityGroupName=admin-servers

    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 80 0.0.0.0/0 'http-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 80 80 ::/0 'http-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 443 0.0.0.0/0 'https-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 443 443 ::/0 'https-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 3005 0.0.0.0/0 'node-admin-server-ingress'
    # EGRESS RULES
    helpers/securityGroupRuleAddIp.sh $securityGroupName egress -1 -1 0.0.0.0/0 'default-egress'
    
    #
    # karan Servers
    securityGroupName=karan-servers

    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 80 0.0.0.0/0 'http-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 80 80 ::/0 'http-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 443 0.0.0.0/0 'https-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 443 443 ::/0 'https-v6-ingress'
    # EGRESS RULES
    helpers/securityGroupRuleAddIp.sh $securityGroupName egress -1 -1 0.0.0.0/0 'default-egress'
    
    #
    # Utility Servers
    securityGroupName=utility-servers

    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 80 0.0.0.0/0 'http-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 80 80 ::/0 'http-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 443 0.0.0.0/0 'https-ingress'
    helpers/securityGroupRuleAddIpV6.sh $securityGroupName ingress tcp 443 443 ::/0 'https-v6-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 6033 0.0.0.0/0 'proxy-sql-server-ingress'
    helpers/securityGroupRuleAddIp.sh $securityGroupName ingress tcp 3111 0.0.0.0/0 'puppeteer-server-ingress'
    # EGRESS RULES
    helpers/securityGroupRuleAddIp.sh $securityGroupName egress -1 -1 0.0.0.0/0 'default-egress'

fi
