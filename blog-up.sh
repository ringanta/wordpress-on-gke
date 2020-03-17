#!/bin/bash

set -e

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm list | grep nfs-server >/dev/null || \
    helm install nfs-server stable/nfs-server-provisioner --set persistence.enabled=true,persistence.size=10Gi

helm list | grep eng-blog >/dev/null || \
    helm install eng-blog bitnami/wordpress \
        --set mariadb.enabled=false \
        --set externalDatabase.host=34.87.88.170 \
        --set externalDatabase.user=wordpress \
        --set externalDatabase.password=wordpresspassword \
        --set externalDatabase.database=wordpress \
        --set externalDatabase.port=3306 \
        2>/dev/null

# Wait until Wordpress pod running
kubectl rollout status deployment/eng-blog-wordpress

SERVICE_IP=$(kubectl get svc --namespace default eng-blog-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
WP_PASS=$(kubectl get secret --namespace default eng-blog-wordpress -o jsonpath="{.data.wordpress-password}" 2>/dev/null | base64 --decode)
echo "WordPress URL: http://$SERVICE_IP/"
echo "WordPress Admin URL: http://$SERVICE_IP/admin"
echo "Wordpress Username: user"
echo "Wordpress Password: $WP_PASS"