#!/bin/bash -e
# 
# Copyright 2021 Carnegie Mellon University.
# Released under a BSD (SEI)-style license, please see LICENSE.md in the
# project root or contact permission@sei.cmu.edu for full terms.

#############################
#   Foundry Stack Install   #
#############################

# Change to the current directory
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../scripts/utils
import_vars ../env
kubectl config set-context --current --namespace=default

# Forward coredns to host dnsmasq
kubectl get configmap/coredns -n kube-system -o yaml | sed "s/\/etc\/resolv.conf/$DNS_01/" | kubectl replace -f -
kubectl rollout restart deployment/coredns -n kube-system

# Disable HSTS
kubectl patch configmap $INGRESS_CONFIGMAP \
                        --patch "$(cat ingress-hsts-disable.yaml)" \
                        --namespace $INGRESS_NAMESPACE

# Add host certificate
kubectl create secret tls appliance-cert --key certs/host-key.pem --cert certs/host.pem --dry-run=client -o yaml | kubectl apply -f -
# Add root ca
if [[ -f certs/root-ca.pem ]]; then
  kubectl create secret generic appliance-root-ca --from-file=appliance-root-ca=certs/root-ca.pem --dry-run=client -o yaml | kubectl apply -f -  
  kubectl create configmap appliance-root-ca --from-file=root-ca.crt=certs/root-ca.pem --dry-run=client -o yaml | kubectl apply -f -
fi
# Add vsphere cert prevent failing if it doesen't exist
if [[ -f certs/vsphere.pem ]] && [[ -f certs/root-ca.pem ]]; then
  kubectl create configmap appliance-root-ca --from-file=root-ca.crt=certs/root-ca.pem --from-file=vsphere-ca.crt=certs/vsphere.pem --dry-run=client -o yaml | kubectl apply -f - 
fi
# Install NFS server
helm_deploy -r ../env -p ../helm -u -f nfs-server-provisioner.values.yaml kvaps/nfs-server-provisioner

# Install local private registry
helm_deploy -r ../env -p ../helm -u --wait -f docker-registry.values.yaml twuni/docker-registry
envsubst < docker-cache.values.yaml | helm upgrade --install -f - docker-cache twuni/docker-registry
#helm_deploy -r ../env -p ../helm -u --wait -f docker-cache.values.yaml twuni/docker-registry

# Install PostgreSQL and pgAdmin4
helm_deploy -r ../env -p ../helm -u --wait -f postgresql.values.yaml bitnami/postgresql

# Install pgAdmin4
kubectl create secret generic pgpassfile --from-literal=pgpassfile=postgresql:5432:\*:$POSTGRES_USER:$POSTGRES_PASS --dry-run=client -o yaml | kubectl apply -f -
helm_deploy -r ../env -u -p ~/.helm -f pgadmin4.values.yaml runix/pgadmin4

# Install code-server (browser-based VS Code)
helm_deploy -r ../env -p ../helm -u -f code-server.values.yaml nicholaswilde/code-server

# Kubernetes Dashboard
# helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# helm upgrade --install -f kubernetes-dashboard.values.yaml kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
# Add root CA to chart values
# ed -s staticweb.values.yaml <<< $'/cacert:/s/\"\"/|-/\n/cacert:/r !sed "s/^/  /" certs/root-ca.pem\nw'

# cp certs/root-ca.pem web/root-ca.crt

# add host entry
external_ip=$(wait_external_ip $INGRESS_NAMESPACE-nginx-$INGRESS_CONTROLLER_NAME $INGRESS_NAMESPACE)
echo "The External IP is $external_ip"
echo "ADDING HOST ENTRY"
add_host_entry $external_ip $DOMAIN

# Install Gitea
git config --global init.defaultBranch main
kubectl exec postgresql-0 -- psql "postgresql://$POSTGRES_USER:$POSTGRES_PASS@localhost" -c 'CREATE DATABASE gitea;' || true
helm_deploy -r ../env -p ../helm -u -f gitea.values.yaml gitea/gitea
timeout 5m bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' https://$DOMAIN/gitea)" != "200" ]]; do sleep 5; ./setup-gitea; done'


# Install Common foundry apps
if [ $OAUTH_PROVIDER = keycloak ]; then 
  replace_vars crucible.json
  replace_vars crucible.quarkus
  kubectl create configmap dod-certs \
    --from-file=issuers-dod-sei.crt=certs/issuers-dod-sei.crt \
    -n $INGRESS_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret generic dod-certs \
    --from-file=ca.crt=certs/issuers-dod-sei.crt -n $INGRESS_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret generic keycloak-truststore \
    --from-file=truststore.jks=./certs/truststore.jks \
    --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret generic keycloak-import \
    --from-file=realm.json=crucible.json \
    --from-file=customreg.yaml=crucible.yaml \
    --from-file=quarkus.properties=crucible.quarkus \
    --dry-run=client -o yaml | kubectl apply -f -
  kubectl exec postgresql-0 -- psql "postgresql://postgres:MTM2Yjc0ZjJhZjE0ZmZkMWNk@localhost" -c 'CREATE DATABASE keycloak;' || true
  replace_vars ./keycloak.values.yaml
  helm upgrade --install --version 14.4.0 -f keycloak.values.yaml keycloak bitnami/keycloak
elif [ $OAUTH_PROVIDER = identity ]; then 
 hin_o -r ../../appliance-vars -u -v 0.2.0 -p ~/.helm -f identity.values.yaml sei/identity
fi


# if [ keycloak = identity ]; then 
#   kubectl create configmap dod-certs --from-file=issuers-dod-sei.crt=certs/issuers-dod-sei.crt -n ingress --dry-run=client -o yaml | kubectl apply -f -
#   kubectl create secret generic dod-certs --from-file=ca.crt=certs/issuers-dod-sei.crt -n ingress --dry-run=client -o yaml | kubectl apply -f -
#   replace_vars ./identity-cac.values.yaml
#   helm upgrade --install --wait --version 0.2.0 -f identity-cac.values.yaml identity sei/identity
#   #helm_deploy -r ../env -u -v 0.2.0 -p ~/.helm -f identity-cac.values.yaml sei/identity
# else
#   helm_deploy -r ../env -u -v 0.2.0 -p ~/.helm -f identity.values.yaml sei/identity
# fi
