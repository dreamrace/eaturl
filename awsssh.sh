#!/bin/bash

# AWS SSH

if [ -z "$1" ]
then 
    echo "Please enter a name"
    exit 1
fi
resp=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1 | jq -r ".Reservations[].Instances[].PublicIpAddress")
if [ -z "$resp" ]
then
    echo "Host not found"
    exit 1
fi
ssh ec2-user@$resp