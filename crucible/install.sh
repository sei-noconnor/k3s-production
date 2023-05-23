#!/bin/bash -xe
# 
# Copyright 2021 Carnegie Mellon University.
# Released under a BSD (SEI)-style license, please see LICENSE.md in the
# project root or contact permission@sei.cmu.edu for full terms.

#############################
#   Crucible Stack Install   #
#############################

# Change to the current directory
cd "$(dirname "${BASH_SOURCE[0]}")"
source ../scripts/utils
import_vars ../env
kubectl config set-context --current --namespace=default
MKDOCS_DIR=~/k3s-production/mkdocs

./setup-gitlab
# # Crucible Stack install
if [[ ${IMPORT_CONTENT-false} = false ]]; then 
  helm_deploy -r ../env -p ../helm -u -v 1.4.1 -f player.values.yaml sei/player
  helm_deploy -r ../env -p ../helm -u -v 1.4.1 -f caster.values.yaml sei/caster
  helm_deploy -r ../env -p ../helm -u -v 1.4.0 -f alloy.values.yaml sei/alloy

  # get MOID for steamfitter
  echo "Attempting to get vsphere cluster"
  MOID=$(pwsh -c 'Connect-VIServer -server $env:VSPHERE_SERVER -user $env:VSPHERE_USER -password $env:VSPHERE_PASS | Out-Null; Get-Cluster -Name $env:VSPHERE_CLUSTER | select -ExpandProperty id')
  MOID=$(echo "${MOID}" | rev | cut -d '-' -f 1,2 | rev)
  if [[ -n ${MOID} ]]; then
    sed -i "s/VmTaskProcessing__ApiParameters__clusters:.*/VmTaskProcessing__ApiParameters__clusters: ${MOID}/" "steamfitter.values.yaml"
    echo "vsphere cluster set"
  fi

  helm_deploy -r ../env -p ../helm -u -v 1.4.0 -f steamfitter.values.yaml sei/steamfitter
  helm_deploy -r ../env -p ../helm -u -v 13.0.0 --wait -f mongodb.values.yaml bitnami/mongodb
  helm_deploy -r ../env -p ../helm -u -v 0.80.0 --wait --timeout 10m -f stackstorm-min.values.yaml stackstorm/stackstorm-ha
fi

# Add crucible docs to mkdocs-material
sed -i '/crucible.md/d' $MKDOCS_DIR/.gitignore
git -C $MKDOCS_DIR add -A || true
git -C $MKDOCS_DIR commit -m "Add Crucible Docs" || true
git -C $MKDOCS_DIR push -u https://administrator:YmFhMjMyZjVmYzhkYjk3ODc1@crucible.covert-cloud.com/gitea/foundry/mkdocs.git --all || true
