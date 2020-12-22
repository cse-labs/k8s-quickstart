# Kubernetes Setup

> Setup Kubernetes on an Azure VM (bare metal)

## Prerequisites

- Azure CLI ([download](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest))

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

- Copy your local id_rsa and id_rsa.pub values to ~/.ssh. This will allow you to ssh into the VM from your local machine if you lose access to the codespace.
- `chmod 700 ~/.ssh/id_rsa*`

If running locally, you can check for existing ssh keys. More info [here](https://docs.github.com/en/github-ae@latest/github/authenticating-to-github/checking-for-existing-ssh-keys).

```bash

# for linux
ls -al ~/.ssh

# for windows
dir %HOMEDRIVE%%HOMEPATH%\.ssh

```

If you dont have an existing public or private key pair, generate a new one. More info [here](https://docs.github.com/en/github-ae@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

```bash

ssh-keygen -b 4096 -C "your_email@example.com"

```

## Create VM

> Note: If you are using a shared subscription, use a unique name for the resource group below to avoid naming collisions with others in the shared subscription.

```bash

# start in this directory
cd 02-Bare-metal-setup

# Create a resource group
# If you are using a shared subscription, prefix the resource group name with something unique like your alias.
# example: az group create -l westus2 -n [UNIQUE_PREFIX]-k8s-qs-rg
az group create -l westus2 -n k8s-qs-rg

# Create an Ubuntu VM and install prerequisites
# If using a shared subscription, update "-g k8s-qs-rg" to your updated resource group name from the previous command
az vm create -g k8s-qs-rg --admin-username codespace -n k8s-qs --size standard_d2s_v3 --nsg-rule SSH --image Canonical:UbuntuServer:18.04-LTS:latest --os-disk-size-gb 128 --generate-ssh-keys --custom-data startup.sh --query publicIpAddress -o tsv
# This will output an IP address

```

## SSH into VM

```bash

# ssh into the VM using the IP address from the previous command, replacing "YourIPAddress"
ssh codespace@YourIPAddress

# clone this repo

cd ~

# If you have problem cloning with your default password, create a Personal Access token at https://github.com/settings/tokens.
# You only need the top level "repo" permissions checked.
# Use the personal access token as the password
git clone https://github.com/retaildevcrews/k8s-quickstart

cd k8s-quickstart/02-Bare-metal-setup

# make sure PIP is set correctly
echo $PIP

# check setup status (until done)
cat ~/status

```

### Initialize cluster

```bash

# install k8s controller
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address $PIP
# The final output shows how to add more nodes to the cluster. Save the "kubeadm join" command for later use

### WARNING ###
# This will delete your existing kubectl configuration
# Make sure to back up or merge manually
###############

# setup your config file
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown -R $(id -u):$(id -g) $HOME/.kube

# Inspect the kubeconfig file
kubectl config view --raw

# Fetch information about the node
kubectl get nodes

kubectl get nodes -o yaml

kubectl describe nodes k8s-qs

# add flannel network overlay
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml --namespace=kube-system

# remove the taint to schedule normal pods on the control plane
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

- [app/README.md](app/README.md)

## Optional: Add second node to your cluster

Run the following commands in a new terminal to add a second node to the cluster.

```bash

# Get the vnet of the first node
# The output is the vnet name
az network vnet list -g k8s-qs-rg --query "[].name" -o tsv

# Get the subnet of the first node
# The output is the subnet name
az network vnet list -g k8s-qs-rg --query "[].subnets[].name" -o tsv

# Create a second VM in the same vnet and subnet
# replace [VNET_NAME], and [SUBNET_NAME]
az vm create -g k8s-qs-rg --admin-username codespace -n k8s-qs-1 --vnet-name [VNET_NAME] --subnet [SUBNET_NAME] --size standard_d2s_v3 --nsg-rule SSH --image Canonical:UbuntuServer:18.04-LTS:latest --os-disk-size-gb 128 --custom-data startup.sh --query publicIpAddress -o tsv
# This will output an IP address for the second VM

# SSH into the new VM, replacing "YourIPAddress"
ssh codespace@YourIPAddress

# run the "kubeadm join" command that was saved earlier
# example:
# sudo kubeadm join 10.0.0.4:6443 --token [TOKEN] --discovery-token-ca-cert-hash [CA_CERT_HASH]

```
