#!/bin/sh

printf "List of Hosted Zones (please check on console): "
printf "$(aws route53 list-hosted-zones)"
exit 0