#!/bin/bash 
# 
# Copyright 2021 Carnegie Mellon University.
# Released under a BSD (SEI)-style license, please see LICENSE.md in the
# project root or contact permission@sei.cmu.edu for full terms.

# Change to the current directory
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../scripts/utils
import_vars ../env
kubectl config set-context --current --namespace=default
git checkout HEAD -- crucible.quarkus
git checkout HEAD -- crucible.json
helm delete keycloak
kubectl delete secret keycloak-import
kubectl delete secret keycloak-truststore
kubectl exec postgresql-0 -- psql "postgresql://$POSTGRES_USER:$POSTGRES_PASS@localhost" -c 'DROP DATABASE keycloak WITH (FORCE);' || true
sleep 10
replace_vars crucible.quarkus
replace_vars baby-yoda.json
kubectl exec postgresql-0 -- psql "postgresql://postgres:MTM2Yjc0ZjJhZjE0ZmZkMWNk@localhost" -c 'CREATE DATABASE keycloak;' || true
kubectl create secret generic keycloak-truststore \
    --from-file=truststore.jks=./certs/truststore.jks \
    --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic keycloak-import \
    --from-file=realm.json=baby-yoda.json \
    --from-file=customreg.yaml=crucible.yaml \
    --from-file=quarkus.properties=crucible.quarkus \
    --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install --version 14.4.0 -f keycloak.values.yaml keycloak bitnami/keycloak