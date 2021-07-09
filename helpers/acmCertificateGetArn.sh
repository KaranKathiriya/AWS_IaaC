#!/bin/sh

printf "List of VPCs (please check on console): "
printf "$(aws acm list-certificates)"
exit 0