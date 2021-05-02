# Setup Kubernetes Development Cluster

## New Content

### [GitHub Codespaces](https://github.com/features/codespaces) is the easiest way to create a developer cluster

- Follow the setup instructions: [Dev Cluster on Codespaces](https://github.com/retaildevcrews/akdc-kind)

## Azure VM Setup

> Setup a single node Kubernetes development cluster on an Azure VM

### Key learnings

- Create an Azure VM
- Create a single-node Kubernetes cluster on the VM
- Verify the cluster

### Prerequisites

- Bash or Windows cmd shell (tested on GitHub Codespaces, Mac, Ubuntu, WSL2, Azure Cloud Shell and Windows cmd)
- Azure CLI ([download](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest))
- Visual Studio Code (optional) ([download](https://code.visualstudio.com/download))
- kubectl (optional) - <https://kubernetes.io/docs/tasks/tools/>

### Host VM Requirements

- tested on `Ubuntu 18.04 LTS`
- minimum 2 cores with 2 GB RAM

## Initial Setup

### Clone this Repo

```bash

# change to the directory where you keep your repos

git clone https://github.com/retaildevcrews/k8s-quickstart.git

# start in the scripts directory
cd k8s-quickstart/03-Dev-Cluster-Setup/scripts/

```

### Login to Azure

```bash

az account list -o table

# login to Azure (if necessary)
az login

# select subscription (if necesary)
az account set -s YourSubscriptionName

```

### Create Resource Group

```bash

### bash
# change your resource group name and location if desired

export AKDC_LOC=westus2
export AKDC_RG=akdc

# Create a resource group

az group create -l $AKDC_LOC -n $AKDC_RG

### Windows

# change your resource group name and location if desired

set AKDC_LOC=westus2
set AKDC_RG=akdc

# Create a resource group

az group create -l %AKDC_LOC% -n %AKDC_RG%

```

## Create Azure VM

> The Azure command takes about 5 minutes to complete

```bash

### bash

# These commands should be executed from 03-Dev-Cluster-Setup/scripts directory.

# create an Ubuntu VM and install k8s prerequisites
# save IP address into the AKDC_IP env var

export AKDC_IP=$(az vm create \
  -g $AKDC_RG \
  --admin-username akdc \
  -n akdc \
  --size standard_d2s_v3 \
  --nsg-rule SSH \
  --image Canonical:UbuntuServer:18.04-LTS:latest \
  --os-disk-size-gb 128 \
  --generate-ssh-keys \
  --query publicIpAddress -o tsv \
  --custom-data startup.sh)
# Notice the path of the startup.sh file.

# This will output an IP address into the AKDC_IP env var
echo $AKDC_IP

# (optional) open NodePort range on NSG
az network nsg rule create -g $AKDC_RG \
--nsg-name akdcNSG --access allow \
--description "AKDC Ports" \
--destination-port-ranges 30000-32767 \
--protocol tcp \
-n AkdcPorts --priority 1200

# SSH into the VM
ssh akdc@${AKDC_IP}

### Windows

# create an Ubuntu VM and install k8s
# save IP address into the AKDC_IP env var

for /f %f in (' ^
  az vm create ^
  -g %AKDC_RG% ^
  --admin-username akdc ^
  -n akdc ^
  --size standard_d2s_v3 ^
  --nsg-rule SSH ^
  --image Canonical:UbuntuServer:18.04-LTS:latest ^
  --os-disk-size-gb 128 ^
  --generate-ssh-keys ^
  --query publicIpAddress -o tsv ^
  --custom-data startup.sh') ^
do set AKDC_IP=%f

echo %AKDC_IP%

# (optional) open NodePort range on NSG
az network nsg rule create -g %AKDC_RG% ^
--nsg-name akdcNSG --access allow ^
--description "AKDC Ports" ^
--destination-port-ranges 30000-32767 ^
--protocol tcp ^
-n AkdcPorts --priority 1200

ssh akdc@%AKDC_IP%

```

## Setup Kubernetes

### Wait for setup to complete

```bash

# from a bash shell in the VM
# this will tell you when the user data script is done
tail -f status

```

### Install Kubernetes

```bash

sudo apt-get install -y containerd.io kubectl kubelet kubeadm kubernetes-cni

# (optional) install oh-my-bash kubectl aliases
sed -i "s/^plugins=($/plugins=(\n  kubectl/g" .bashrc
source .bashrc

```

### Install containerd prerequisites

containerd requires the `overlay file system` kernel module and the `bridge netfilter` loadable kernel module.

> There are two types of Linux Kernel Modules: Static Modules and Loadable(Dynamic) Modules.
>
> Static modules must to loaded during boot time.
> Loadable modules can be added dynamically at runtime using `modprobe` or `insmod`

```bash

# enable bridge in sysctl
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# update config
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# config crictl to use containerd
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: true
EOF

# Apply sysctl params
sudo sysctl --system

# add loadable modules to kernel
sudo modprobe overlay
sudo modprobe br_netfilter

# Make sure the modules are loaded
lsmod | grep -iE 'overlay|netfilter'

```

#### Apply config changes

The above config changes will be used when the VM boots. To avoid a VM restart, run the following commands to apply the changes to the running VM.

```bash

# Configure containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

```

### Initialize Cluster

`kubeadm` is a tool for creating a Kubernetes cluster that conforms to best practices. This simplifies the process of getting a cluster up and running.

For more information about the Kubernetes components, go here. [Kubernetes components](https://kubernetes.io/docs/concepts/overview/components/).

> Note: If you chose to use a different CIDR, you'll also need to change the CIDR in flannel yaml file used in [Install Pod Network](#install-pod-network) step.

```bash

# pull the k8s images
sudo kubeadm config images pull

# install k8s controller
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address $PIP --cri-socket /run/containerd/containerd.sock

# view container images on the VM
sudo crictl images list

# view containers that are now running on the VM
sudo crictl ps

```

### Setup kubeconfig

kubeconfig files are used to organize information and authentication mechanisms for clusters. The `kubectl` tool uses this information to communicate with the cluster.

```bash

# setup your config file
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown -R $(id -u):$(id -g) $HOME/.kube

# view the contents of the kubeconfig with kubectl
kubectl config view

# view the current context
kubectl config current-context

# fetch the nodes in the cluster
kubectl get nodes -o wide

# get the node definition in yaml format
kubectl get nodes akdc -o yaml

# query for specific fields using jsonpath
kubectl get nodes akdc -o jsonpath="{.status.nodeInfo.containerRuntimeVersion}"

# an example query fetching data from lists
kubectl get nodes akdc -o jsonpath="{.status.images[0].names[0]}"

```

### Modify kubeconfig

kubeconfig file can be edited and gives the user flexibility on how to access their clusters.

```bash

# view the current context
kubectl config current-context

# create a new context, "dev", with the same cluster and user information
kubectl config set-context dev --cluster=kubernetes --user=kubernetes-admin

# switch to the new context
kubectl config use-context dev

# test the context by fetching information from the cluster
kubectl get nodes

# switch back to the original context
kubectl config use-context kubernetes-admin@kubernetes

```

### Install pod network

Kubernetes uses a plugin architecture for the network. It has requirements for it's network. Network plugins then provide the implementation details that satisfy those requirements. A couple of options are Flannel and Calico.

For more information about other available network implementations, go here. [Network implementations](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model).

Also check out this [table of comparison](https://biarca.io/2018/10/choosing-the-right-network-for-your-kubernetes-cluster/) between different network implementation.

This cluster uses Flannel

```bash

# add flannel network overlay
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml --namespace=kube-system

```

### Schedule pods in control plane

This single node is the control plane node. It is also known as the master control node.

> By default, your cluster will not schedule `pods` on the `control plane node` for security reasons.

This can be updated by removing a specific `taint` from the node.

```bash

# view the current taints on the node
kubectl get nodes akdc -o jsonpath="{.spec.taints}"

# try to run a pod in the cluster
kubectl run hello-world --image hello-world --restart=Never

# view information about this new pod
# notice that the pod cannot be scheduled
kubectl describe pod hello-world

# remove the taint to schedule normal pods on the control plane
# this lets you run a `single-node development cluster`
kubectl taint nodes --all node-role.kubernetes.io/master-

# view information about the pod and note the status updates
kubectl describe pod hello-world

# view logs from the hello-world pod
kubectl logs hello-world

# view pods running in the cluster
kubectl get pods --all-namespaces -o wide

```

### Install Docker CLI

- Optional - install Docker
  - The cluster uses `containerd` as the runtime
  - Install Docker for development

```bash

sudo apt-get install -y docker-ce docker-ce-cli

```

### Upgrade Ubuntu

```bash

sudo apt-get dist-upgrade -y
sudo apt-mark hold kubelet kubeadm kubectl

```

### Install Metal LB

- Optional - install Metal Load Balancer
  - This is only necessary if you want to create a Kubernetes load balancer to expose a public endpoint

```bash

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
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${PIP}-${PIP}
EOF

```
