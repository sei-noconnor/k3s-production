#!/bin/bash -e
# Change to the current directory
directory="$(dirname "${BASH_SOURCE[0]}")"
cd $directory
source $directory/scripts/utils
import_vars $directory/env
export BASE_IP=$(echo $DEFAULT_NETWORK |cut -d"." -f1-3)
MKDOCS_DIR=~/k3s-production/mkdocs

# Replace variables in files
replace_vars $directory/common '.*\.(json|conf)'
replace_vars $directory/crucible '.*\.(json|conf|sql)'
replace_vars $directory/k3s-ansible '.*\.(json|conf|yaml|yml)'
replace_vars $directory/terraform '.*\.(json|conf|yaml|yml|auto.tfvars)'
replace_vars $directory/values '.*\.(json|conf|yaml|yml)'
replace_vars $directory/mkdocs/docs '.*\.(md)'
chmod +x $directory/crucible/setup-gitlab
chmod +x $directory/crucible/import-content

# Add Repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add runix https://helm.runix.net/
helm repo add nicholaswilde https://nicholaswilde.github.io/helm-charts/
helm repo add kvaps https://kvaps.github.io/charts
helm repo add gitea https://dl.gitea.io/charts/
helm repo add sei https://helm.cyberforce.site/charts
helm repo add stackstorm https://helm.stackstorm.com/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add longhorn https://charts.longhorn.io
helm repo add twuni https://helm.twun.io
helm repo update

echo "Sleeping for 10 seconds ctrl+c to cancel"
sleep 10

# Install Powershell and PowerCLI (vcenter, steamfitter)
pwsh -c 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; Install-Module -Name VMWare.PowerCLI -Confirm:$false'
# Update permissions for .config and .local directory (PowerCLI install)
chown -f -R $USER:$USER ~/.config ~/.local
pwsh -c 'Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -InvalidCertificateAction Ignore -Confirm:$false | Out-Null'



# Download vsphere cert
if [[ $VSPHERE_DOWNLOAD_CERT = true ]]; then 
  download_vsphere_cert $VSPHERE_SERVER 443 $PWD/common/certs/vsphere.pem
fi

if [[ $GENERATE_CERTS = true ]]; then 
  $directory/common/certs/generate-certs -loglevel 3
  # reset, so we don't clobber
  sed -i -e "s/GENERATE_CERTS=.*/GENERATE_CERTS=false/" env
fi

if [[ $IMPORT_CERTS = true ]]; then 
  import_root_ca $directory/common/certs/root-ca.pem
  sed -i -e "s/IMPORT_CERTS=.*/IMPORT_CERTS=false/" env
fi

if [[ $RUN_TERRAFORM = true ]]; then
  # TODO
  echo "Future Automation"
fi

if [[ $RUN_ANSIBLE = true ]]; then 
  # TODO
  echo "Future Automation"
fi

#Remove mkdocs exceptions
sed -i '/^!/d' $MKDOCS_DIR/.gitignore

# Install infrastructure
envsubst < $directory/values/metalLB/01-namespace.yaml | kubectl apply -n $METAL_NAMESPACE -f -
envsubst < $directory/values/metalLB/02-metallb.yaml | kubectl apply -n $METAL_NAMESPACE -f -
envsubst < $directory/values/metalLB/03-metallb-config.yaml | kubectl apply -n $METAL_NAMESPACE -f -
#kubectl apply -n $METAL_NAMESPACE -f $directory/values/metalLB
helm_deploy -r ./env -p helm -v 4.6.1 -u -f $directory/values/nginx/ingress-nginx.values.yaml ingress-nginx/ingress-nginx --wait -n $INGRESS_NAMESPACE --create-namespace

kubectl create secret tls appliance-cert --key $directory/common/certs/host-key.pem --cert $directory/common/certs/host.pem --dry-run=client -o yaml | kubectl apply -f - -n $LONGHORN_NAMESPACE
helm_deploy -r ./env -p helm -v 1.3.1 -u -f $directory/values/longhorn/longhorn.values.yaml longhorn/longhorn --wait -n $LONGHORN_NAMESPACE --create-namespace

# Always run common apps. 
apps="common,$1"
IFS=',' read -a stacks <<< $apps
echo "The following apps will be installed ${stacks[@]}"
for stack in ${stacks[@]}; do
  # replace_vars $directory/$stack/setup-$stack
  chmod +x $directory/$stack/install.sh
  echo "Installing $stack with script located at $directory/$stack/install.sh"
  $directory/$stack/install.sh
  sleep 15
done

if [[ $IMPORT_CONTENT = true ]]; then 
  # TODO
  $directory/crucible/import-content
  sed -i -e "s/IMPORT_CONTENT=.*/IMPORT_CONTENT=false/" env
fi

# Redeploy mkdocs to update
echo "$PWD"
ed -s common/mkdocs-material.values.yaml <<< $'/cacert:/s/\"\"/|-/\n/cacert:/r !sed "s/^/  /" ./common/certs/root-ca.pem\nw' || true
#cp ./common/certs/root-ca.pem $MKDOCS_DIR/docs/root-ca.crt
git -C $MKDOCS_DIR add -A || true
git -C $MKDOCS_DIR commit -m "Add Root CA" || true
git -C $MKDOCS_DIR push -u https://administrator:$ADMIN_PASS@$DOMAIN/gitea/foundry/mkdocs.git --all || true
helm_deploy -r env -u -p ~/.helm -f common/mkdocs-material.values.yaml sei/mkdocs-material -n default

