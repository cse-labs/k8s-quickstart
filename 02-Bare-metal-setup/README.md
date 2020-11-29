# Kubernetes Setup

> Setup Kubernetes on an Azure VM (bare metal)

- TODO - we could setup from a terminal on the local machine
  - we would have to add the ssh-keygen step
  - this has caused issues in the past with customers but shouldn't be an issue for us
  - need to verify the startup.sh will work on Windows

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

# (optional) Change these environment variables
export qsloc=westus2
export qsuser=codespace

# cmd
set qsdns=YourDNSName
set qsloc=westus2
set qsuser=codespace

# Create a resource group
az group create -l $qsloc -n ${qsdns}-rg

#cmd
az group create -l %qsloc% -n %qsdns%-rg

# update ME= in startup.templ
sed "s/ME=codespace/ME=$qsuser/g" startup.templ > startup.sh
chmod +x startup.sh

# cmd
# copy and edit file if you don't have sed installed
sed "s/ME=codespace/ME=%qsuser%/g" startup.templ > startup.sh

# Create an Ubuntu VM and install prerequisites
az vm create -g ${qsdns}-rg \
--admin-username $qsuser \
--public-ip-address-dns-name $qsdns \
-n k8s-qs \
--size standard_d2s_v3 \
--nsg-rule SSH \
--image Canonical:UbuntuServer:18.04-LTS:latest \
--os-disk-size-gb 128 \
--custom-data startup.sh

#cmd
az vm create -g %qsdns%-rg ^
--admin-username %qsuser% ^
--public-ip-address-dns-name %qsdns% ^
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
ssh ${qsuser}@${qsdns}.${qsloc}.cloudapp.azure.com

# cmd
ssh %qsuser%@%qsdns%.%qsloc%.cloudapp.azure.com

# check setup status (until done)
cat status

# clone this repo
cd~
git clone https://github.com/retaildevcrews/k8s-quickstart
cd k8s-quickstart/02-Bare-metal-setup

# optional - add your local id_rsa.pub key
nano ~/.ssh/authorized_keys
# copy and paste your id_rsa.pub key on a new line

```
