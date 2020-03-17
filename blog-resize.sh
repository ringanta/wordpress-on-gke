#!/bin/bash

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [capacity]"
    exit 1
fi

helm upgrade eng-blog bitnami/wordpress \
    --set mariadb.enabled=false \
    --set externalDatabase.host=34.87.88.170 \
    --set externalDatabase.user=wordpress \
    --set externalDatabase.password=wordpresspassword \
    --set externalDatabase.database=wordpress \
    --set externalDatabase.port=3306 \
    --set replicaCount=$1 \

# Wait until Wordpress pod running
kubectl rollout status deployment/eng-blog-wordpress
