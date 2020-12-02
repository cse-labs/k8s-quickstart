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
# If you are using a shared subscription, prefix the resource group name with something unique like your alias.
az group create -l westus2 -n k8s-qs-rg

# Create an Ubuntu VM and install prerequisites
vm_ip=$(az vm create -g k8s-qs-rg --admin-username codespace -n k8s-qs --size standard_d2s_v3 --nsg-rule SSH --image Canonical:UbuntuServer:18.04-LTS:latest --os-disk-size-gb 128 --custom-data startup.sh --query publicIpAddress -o tsv)

# Print the VM IP address
echo $vm_ip

```

## SSH into VM

```bash

# ssh into the VM
ssh codespace@${vm_ip}

# clone this repo
### TODO - this fails if the repo is private
cd ~

# If you have problem cloning with your default password
# Try creating a Personal Access token at https://github.com/settings/tokens
# And use that as a password
git clone https://USERNAME@github.com/retaildevcrews/k8s-quickstart

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

- app readme [app/README.md](app/README.md)

## Optional: Add second node to your cluster

Run the following commands in a new terminal to add a second node to the cluster.

```bash

# Get the vnet of the first node
vnet=$(az network vnet list -g k8s-qs-rg --query '[].name' -o tsv)

# Get the subnet of the first node
subnet=$(az network vnet list -g k8s-qs-rg --query '[].subnets[].name' -o tsv)

# Create a second VM in the same vnet and subnet
vm_ip2=$(az vm create -g k8s-qs-rg --admin-username codespace -n k8s-qs-1 --vnet-name $vnet --subnet $subnet --size standard_d2s_v3 --nsg-rule SSH --image Canonical:UbuntuServer:18.04-LTS:latest --os-disk-size-gb 128 --custom-data startup.sh --query publicIpAddress -o tsv)

# SSH into the new VM and run the "kubeadm join" command that was saved earlier
ssh codespace@${vm_ip2}

# example:
# sudo kubeadm join 10.0.0.4:6443 --token [TOKEN] --discovery-token-ca-cert-hash [CA_CERT_HASH]

```
