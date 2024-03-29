#!/bin/bash 
# Change to the current directory
DIRECTORY="$(dirname "${BASH_SOURCE[0]}")"
cd $DIRECTORY
helm delete topomojo|| true 
helm delete gameboard || true
helm delete alloy || true 
helm delete caster || true 
helm delete code-server || true 
helm delete gitea || true 
helm delete gitlab || true 
helm delete mongodb || true 
helm delete identity || true 
helm delete kubernetes-dashboard || true 
helm delete player || true 
helm delete steamfitter || true 
helm delete stackstorm-ha || true
helm delete mkdocs-material || true
helm delete pgadmin4 || true
helm delete docker-registry || true
helm delete docker-cache || true
helm delete keycloak || true
echo "Sleeping for 40 seconds"
sleep 20
helm delete postgresql || true 
helm delete nfs-server-provisioner || true 
helm delete ingress-nginx -n ingress || true
helm delete longhorn -n longhorn-system || true
echo "Sleeping for 40 seconds"
sleep 20
kubectl config set-context --current --namespace=default
kubectl delete jobs --all
kubectl delete pvc --all
kubectl delete pv --all
kubectl delete configmap --all
kubectl delete secret --all

echo " Cleaning up volumes, configmaps, secrets and jobs from all namespaces"
kubectl config set-context --current --namespace=ingress
kubectl delete pvc --all
kubectl delete configmap --all
kubectl delete secret --all
kubectl delete job --all

kubectl config set-context --current --namespace=longhorn-system
kubectl delete pvc --all
kubectl delete configmap --all
kubectl delete secret --all
kubectl delete job --all
kubectl config set-context --current --namespace=default

# Remove Folders
find crucible/seed/gitlab -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;