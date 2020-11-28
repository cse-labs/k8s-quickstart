# Kubernetes Setup

> Setup Kubernetes on an Azure VM (bare metal)

- TODO - we could setup from a terminal on the local machine
- we would have to add the ssh-keygen step
- this has caused issues in the past with customers
- but shouldn't be an issue for us

## Login to Azure

```bash

# login to Azure
az login

# select subscription (if necesary)
az account list -o table

az account set -s YourSubscriptionName

```

## Create VM

```bash

#### Change these environment variables
export qsloc=westus2
export qsuser=codespace
export qsdns=YourDNSName

# Create a resource group
az group create -l $qsloc -n ${qsdns}-rg

# Create an Ubuntu VM and install prerequisites
az vm create -g ${qsdns}-rg \
-n $qsuser \
--admin-username $qsuser \
--public-ip-address-dns-name $qsdns \
--size standard_d2s_v3 \
--nsg-rule SSH \
--image Canonical:UbuntuServer:18.04-LTS:latest \
--os-disk-size-gb 128 \
--custom-data startup.sh

```

## SSH into VM

```bash

# ssh into the VM
ssh ${qsdns}.${qsloc}.cloudapp.azure.com

# check setup status (until done)
cat status

# optional - add your local id_rsa.pub key
nano ~/.ssh/authorized_keys
# copy and paste your id_rsa.pub key on a new line

```
