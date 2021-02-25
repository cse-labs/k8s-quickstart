#!/bin/bash

##################################
# replace with your ID (optinonal)
export ME=akdc
##################################

# make some directories we will need
mkdir -p /home/${ME}/.ssh
mkdir -p /home/${ME}/.kube
mkdir -p /home/${ME}/bin
mkdir -p /home/${ME}/.local/bin
mkdir -p /etc/containerd
mkdir -p /etc/systemd/system/docker.service.d
mkdir -p /etc/docker

cd /home/${ME}
echo "starting" >> status

cp /usr/share/zoneinfo/America/Chicago /etc/localtime

# create / add to groups
groupadd docker
usermod -aG sudo ${ME}
usermod -aG admin ${ME}
usermod -aG docker ${ME}
gpasswd -a ${ME} sudo

echo "${ME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users

# oh my bash
git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git .oh-my-bash
cp .oh-my-bash/templates/bashrc.osh-template .bashrc

# add to .bashrc
echo "" >> .bashrc
echo "alias k='kubectl'" >> .bashrc
echo "alias kga='kubectl get all'" >> .bashrc
echo "alias kgaa='kubectl get all --all-namespaces'" >> .bashrc
echo "alias kaf='kubectl apply -f'" >> .bashrc
echo "alias kdelf='kubectl delete -f'" >> .bashrc
echo "alias kl='kubectl logs'" >> .bashrc
echo "alias kccc='kubectl config current-context'" >> .bashrc
echo "alias kcgc='kubectl config get-contexts'" >> .bashrc

echo "export GO111MODULE=on" >> .bashrc
echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> .bashrc
echo 'export PIP=$(ipconfig | tail -n 1)' >> .bashrc
echo 'export PATH="$PATH:$HOME/.dotnet/tools:$HOME/go/bin"' >> .bashrc
echo 'source /usr/share/bash-completion/bash_completion' >> .bashrc
echo 'source <(kubectl completion bash)' >> .bashrc
echo 'complete -F __start_kubectl k' >> .bashrc

# change ownership of home directory
chown -R ${ME}:${ME} /home/${ME}

# set the permissions on .ssh
chmod 700 /home/${ME}/.ssh
chmod 600 /home/${ME}/.ssh/*

# set the IP address
export PIP=$(ip -4 a show eth0 | grep inet | sed "s/inet//g" | sed "s/ //g" | cut -d '/' -f 1 | tail -n 1)

echo "updating (1/7)" > status
apt-get update

echo "install base (2/7)" >> status
apt-get install -y apt-utils dialog apt-transport-https ca-certificates curl software-properties-common

echo "add repos (3/7)" >> status

# add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# add dotnet repo
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list

# add Azure CLI repo
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list

# add kubenetes repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update

echo "install utils (4/7)" >> status
apt-get install -y git wget nano jq zip unzip httpie dnsutils

echo "install libs (5/7)" >> status
apt-get install -y libssl-dev libffi-dev python-dev build-essential lsb-release gnupg-agent bash-completion

echo "install Azure CLI (6/7)" >> status
apt-get install -y azure-cli

# CLI for CRI-compatible container runtimes
echo "install crictl (7/7)" >> status

# config crictl to use containerd
cat <<EOF >> /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: true
EOF

# kubectl auto complete
kubectl completion bash > /etc/bash_completion.d/kubectl
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
complete -F __start_kubectl k

# install jp (jmespath)
VERSION=0.1.3
wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp
chmod +x /usr/local/bin/jp

VERSION="v1.20.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

echo "done" >> status
