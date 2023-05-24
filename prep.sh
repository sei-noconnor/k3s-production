#!/bin/bash -E
# Must be run as sudo
[ `whoami` = root ] || { sudo -E "$0" "$@"; exit $?; }
# Change to the current directory
directory="$(dirname "${BASH_SOURCE[0]}")"
cd $directory
source $directory/scripts/utils
import_vars $directory/env
export BASE_IP=$(echo $DEFAULT_NETWORK |cut -d"." -f1-3)

while [[ "$#" -gt 0 ]]; do
  case "$1" in 
    -r|--replace-vars)
      shift 1
      replace_vars $directory/k3s-ansible '.*\.(json|conf|yaml|yml)'
      replace_vars $directory/terraform '.*\.(json|conf|yaml|yml|auto.tfvars)'
      replace_vars $directory/values '.*\.(json|conf|yaml|yml)'
      exit
      ;;
  esac
done
# Install common packages 
case $(get_distro) in 
  centos|fedora)
    sudo yum update -y
    sudo yum install -y ca-certificates curl software-properties-common apache2-utils jq unzip rename postgresql vim sshpass snapd wget nc nfs-utils
    # symlink snap
    sudo ln -s /var/lib/snapd/snap /snap
    sudo systemctl restart snapd
    # CentOS version of git is way out of date 
    yum install -y \
    https://repo.ius.io/ius-release-el7.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum remove -y git
    yum install -y git236
    ;;
  rhel)
    sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo yum update -y 
    sudo yum install -y ca-certificates curl jq unzip postgresql vim sshpass snapd wget nc nfs-utils
    # enable snap
    sudo systemctl enable --now snapd.socket
    # symlink snap
    sudo ln -s /var/lib/snapd/snap /snap
    if [[ -n $PROXY ]]; then 
      sudo snap set system proxy.http="$PROXY"
      sudo snap set system proxy.http="$PROXY"
    fi
    sudo systemctl restart snapd
    ;;
  ubuntu|debian)
    apt update
    apt install apt-transport-https ca-certificates curl software-properties-common \
    apache2-utils jq unzip rename python postgresql-client vim sshpass snapd  wget nfs-common -y
    ;;
  darwin)
    echo "MacOS is not supported by this script"
    exit;
esac

# Install terraform from utils script
install_terraform
# install ansible from utils script
install_ansible
# Install kubectl
install_kubectl
echo "source <(kubectl completion $(get_shell))" >> ~/.$(get_shell)rc
# Install Helm
install_helm
# Add kubectl and helm bash completion
echo "source <(kubectl completion $(get_shell))" >> ~/.$(get_shell)rc
echo "source <(helm completion $(get_shell)" >> ~/.$(get_shell)rc


# Install retry script
sudo sh -c "curl https://raw.githubusercontent.com/kadwanev/retry/master/retry -o /usr/local/bin/retry && chmod +x /usr/local/bin/retry"

# Install cfssl
curl -sLko /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64
curl -sLko /usr/local/bin/cfssljson https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64
chmod +x /usr/local/bin/cfssl*

# Install Powershell and PowerCLI (vcenter, steamfitter)
sudo snap install powershell --classic

#replace vars
replace_vars $directory/k3s-ansible '.*\.(json|conf|yaml|yml)'
replace_vars $directory/terraform '.*\.(json|conf|yaml|yml|auto.tfvars)'
replace_vars $directory/values '.*\.(json|conf|yaml|yml)'
echo "Finished Prep."
