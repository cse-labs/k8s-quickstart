# Kubernetes Setup

> Setup Kubernetes on an Azure VM (bare metal)

- TODO - we could setup from a terminal on the local machine
  - would have to have az cli installed
    - this has caused issues in the past with customers but shouldn't be an issue for us
  - we would have to add the ssh-keygen step if no ssh key
    - this has caused issues in the past with customers but shouldn't be an issue for us
  - I think I prefer using local terminal if possible

## Login to Azure

```bash

# login to Azure
az login

# select subscription (if necesary)
az account list -o table

az account set -s YourSubscriptionName

```

## Use your SSH key

> Optional - an SSH key is auto-generated when the codespace is created

- Copy your local id_rsa and id_rsa.pub values to ~/.ssh
- `chmod 700 ~/.ssh/id_rsa*`

## Create VM

```bash

# start in this directory
cd 02-Bare-metal-setup

# Create a resource group
az group create -l westus2 -n k8s-qs-rg

# Create an Ubuntu VM and install prerequisites
az vm create -g k8s-qs-rg --admin-username codespace -n k8s-qs --size standard_d2s_v3 --nsg-rule SSH --image Canonical:UbuntuServer:18.04-LTS:latest --os-disk-size-gb 128 --custom-data startup.sh --query publicIpAddress -o tsv

# This will output an IP address

```

## SSH into VM

```bash

# ssh into the VM
ssh codespace@YourIPAddress

# clone this repo
### TODO - this fails if the repo is private
cd~
git clone https://github.com/retaildevcrews/k8s-quickstart
cd k8s-quickstart/02-Bare-metal-setup

# make sure PIP is set correctly
echo $PIP

# check setup status (until done)
cat status

```

### Initialize cluster

```bash

# install k8s controller
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address $PIP

### WARNING ###
# This will delete your existing kubectl configuration
# Make sure to back up or merge manually
###############

# setup your config file
sudo rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown -R $(id -u):$(id -g) $HOME/.kube

# add flannel network overlay
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml --namespace=kube-system

# add the taint to schedule normal pods on the control plane
# this let you run a "one node cluster" for development
k taint nodes --all node-role.kubernetes.io/master-

# patch kube-proxy for metal LB
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
sed -e 's/mode: ""/mode: "ipvs"/' | \
kubectl apply -f - -n kube-system

## Install metal LB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.4/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.4/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# create metal LB config map
sed -e "s/{PIP}/${PIP}/g" metalLB.yaml | k apply -f -

```

## Setup app

- app readme <app/README.md>
