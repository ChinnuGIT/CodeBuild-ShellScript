#!/bin/bash
set -eou pipefail

CLUSTERNAME="tomcat-cluster"
REGION="us-east-2"
if [ -z "$CLUSTERNAME" ]; then
    echo "You must specify a cluster to take down"
    exit 1
fi


# find all instances that are part of the cluster:
for instanceID in $(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Cluster,Values=$CLUSTERNAME" | jq -r ".Reservations[].Instances[].InstanceId"); do
    echo "Terminating $instanceID"
    aws ec2 terminate-instances --instance-ids $instanceID | jq .
done

ecs-cli down --force --cluster-config "$CLUSTERNAME"

