#!/bin/sh
SECURITY_GROUP_NAME=$1
# Get the description for the default security groups.  We store it in the `DESCRIPTION` variable so we don't need to re-fetch this.

DESCRIPTION="$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
    --query 'SecurityGroups[*]' --output json)"

# Run through all security groups.

for group_id in $(echo "$DESCRIPTION" | jq -r '.[] | .GroupId'); do
    echo "Removing rules from security group $group_id..." 1>&2

# Get the description for this group specifically.

GROUP_DESCRIPTION="$(echo "$DESCRIPTION" | \
      jq "map(select(.GroupId == \"$group_id\")) | .[0]")"

# Run through ingress permissions.

  {
    IFS=$'\n'  # Make sure we only split on newlines.
    for ingress_rule in $(echo "$GROUP_DESCRIPTION" | \
            jq -c '.IpPermissions | .[]'); do
        echo "Removing ingress rule: $ingress_rule" 1>&2
        aws ec2 revoke-security-group-ingress \
            --group-id "$group_id" \
            --ip-permissions "$ingress_rule"
    done
    unset IFS
  }

# Run through egress permissions.

  {
    IFS=$'\n'  # Make sure we only split on newlines.
    for egress_rule in $(echo "$GROUP_DESCRIPTION" | \
            jq -c '.IpPermissionsEgress | .[]'); do
        echo "Removing egress rule: $egress_rule" 1>&2
        aws ec2 revoke-security-group-egress \
            --group-id "$group_id" \
            --ip-permissions "$egress_rule"
    done
    unset IFS
  }

done