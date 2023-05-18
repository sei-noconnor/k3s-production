#!/bin/bash 
# 
# Copyright 2021 Carnegie Mellon University.
# Released under a BSD (SEI)-style license, please see LICENSE.md in the
# project root or contact permission@sei.cmu.edu for full terms.

# Change to the current directory
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../scripts/utils
import_vars ../env
realm=$1
kubectl config set-context --current --namespace=default
kubectl exec keycloak-0 -- /bin/bash -c "/opt/bitnami/keycloak/bin/kc.sh export --dir /tmp --realm $realm --users realm_file"
kubectl cp default/keycloak-0:tmp/$realm-realm.json ./baby-yoda.json