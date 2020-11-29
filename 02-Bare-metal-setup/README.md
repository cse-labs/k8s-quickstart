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

#### Change this environment variable
export qsdns=YourDNSName

# cmd
set qsdns=YourDNSName

# Create a resource group
az group create -l westus2 -n ${qsdns}-rg

# cmd
az group create -l westus2 -n %qsdns%-rg

# Create an Ubuntu VM and install prerequisites
az vm create -g ${qsdns}-rg \
--public-ip-address-dns-name $qsdns \
--admin-username codespace \
-n k8s-qs \
--size standard_d2s_v3 \
--nsg-rule SSH \
--image Canonical:UbuntuServer:18.04-LTS:latest \
--os-disk-size-gb 128 \
--custom-data startup.sh

# cmd
az vm create -g %qsdns%-rg ^
--public-ip-address-dns-name %qsdns% ^
--admin-username codespace ^
-n k8s-qs ^
--size standard_d2s_v3 ^
--nsg-rule SSH ^
--image Canonical:UbuntuServer:18.04-LTS:latest ^
--os-disk-size-gb 128 ^
--custom-data startup.sh

# remove the temporary script
rm startup.sh

# cmd
del startup.sh

```

## SSH into VM

```bash

# ssh into the VM
ssh codespace@${qsdns}.westus2.cloudapp.azure.com

# cmd
ssh codespace@%qsdns%.westus2.cloudapp.azure.com

# check setup status (until done)
cat status

# clone this repo
cd~
git clone https://github.com/retaildevcrews/ngsa
cd ngsa/IaC/BareMetal

```
