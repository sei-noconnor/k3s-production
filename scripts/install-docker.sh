#!/bin/bash
#
# docker install
#
[ `whoami` = root ] || { sudo "$0" "$@"; exit $?; }
apt update
apt install apt-transport-https ca-certificates curl software-properties-common apache2-utils jq unzip rename python postgresql-client -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt install docker-ce -y

mkdir -p /etc/docker
cat <<EOF >> /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m"
  }
}
EOF

groupadd docker -f
usermod -aG docker "${SUDO_USER}"
echo "Added ${SUDO_USER} to docker and sudo group"
systemctl enable docker
systemctl start docker

# install compose
tag=`curl -s https://github.com/docker/compose/releases/latest | awk -F'"' '{print $2}' | awk -F/ '{print $NF}'`
curl -L https://github.com/docker/compose/releases/download/$tag/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo Done installing docker.