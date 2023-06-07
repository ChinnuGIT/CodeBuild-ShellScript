#!/bin/bash
set -eou pipefail

CLUSTERNAME="tomcat-cluster"
REGION="us-east-2"
if [ -z "$CLUSTERNAME" ]; then
    echo "You must specify a cluster to stop all tasks on"
    exit 1
fi

for task in $(aws ecs list-tasks --region "$REGION" --cluster "$CLUSTERNAME" | jq -r ".taskArns[]"); do
    aws ecs stop-task --region "$REGION" --task "$task" --cluster "$CLUSTERNAME" &
    sleep 0.25
    aws ecs delete-task-definitions --region "$REGION" --task "$task" --cluster "$CLUSTERNAME"
done

wait
