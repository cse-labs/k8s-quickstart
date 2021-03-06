# TODO: title

TODO:

- intro
  - purpose
  - show some example commands useful for debugging

## Example setup

TODO:

- scenario description
  - fluentbit is forwarding logs to log analytics
  - we want to rename some long fields names in log analytics to shorter names for easier querying

### Prerequisites

- Azure CLI ([download](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest))
- kubectl ([download](https://kubernetes.io/docs/tasks/tools/#kubectl))

```bash

az login

az account set -s <subscription name or id>

```

### Log Analytics setup

Create a Log Analytics workspace.

```bash

RESOURCE_GROUP="aks-debugging-session"
LOCATION="centralus"
LOG_ANALYTICS_NAME="debugging-log"

# create resource group
az group create -n $RESOURCE_GROUP -l $LOCATION

# Add Log Analytics extension
az extension add -n log-analytics

# create Log Analytics
az monitor log-analytics workspace create -g $RESOURCE_GROUP -l $LOCATION -n $LOG_ANALYTICS_NAME -o table

```

### Cluster setup

Create an AKS cluster.

```bash

AKS_NAME="debugging-aks"

# Determine the latest version of Kubernetes supported by AKS.
# It is recommended to choose the latest version not in preview for production purposes, otherwise choose the latest in the list.
az aks get-versions -l $LOCATION -o table

K8S_VERSION=1.19.7

# Create and connect to the AKS cluster.
# this step usually takes 2-4 minutes
az aks create --name $AKS_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --enable-cluster-autoscaler --min-count 1 --max-count 2 --node-count 1 --kubernetes-version $K8S_VERSION --no-ssh-key

az aks get-credentials -n $AKS_NAME -g $RESOURCE_GROUP

```

### App setup

Deploy a sample application to the cluster. This application will simply emit logs messages to STDOUT.

```bash

# create a namespace
kubectl create namespace logapp

# deploy the sample app
kubectl apply -f logapp.yaml -n logapp

# wait for pods to be ready
kubectl wait pod -n logapp -l app=logapp --for=condition=Ready --timeout=60s

```

### Fluentbit setup

Deploy Fluentbit to send logsapp logs to Log Analytics

```bash

# create namespace
kubectl create namespace fluentbit

# create initial config map
kubectl apply -f 01-configmap.yaml -n fluentbit

# create secret for log analytics
kubectl create secret generic fluentbit-secrets \
  --namespace fluentbit \
  --from-literal=WORKSPACE_ID=$(az monitor log-analytics workspace show -g $RESOURCE_GROUP -n $LOG_ANALYTICS_NAME --query customerId -o tsv) \
  --from-literal=SHARED_KEY=$(az monitor log-analytics workspace get-shared-keys -g $RESOURCE_GROUP -n $LOG_ANALYTICS_NAME --query primarySharedKey -o tsv)

# install fluentbit
helm repo add fluent https://fluent.github.io/helm-charts
helm install fluentbit fluent/fluent-bit -n fluentbit --values fluentbit-values.yaml

kubectl wait pod -n fluentbit -l app.kubernetes.io/instance=fluentbit --for=condition=Ready --timeout=60s

```

## Example debugging workflow

TODO:

- cleanup
- add screenshots
- add modify filter code sections for copy-paste

Edit

- use `kubectl edit` to edit configmap directly on cluster
- use modify config in 02-config-map. this is using the field name from log analytics
- copy fields from log analytics as is

Restart

- use `kubectl delete` with label selector to delete multiple pods
- useful for "restarting" workloads

Observe

- go to log analytics to double check logs
- see that new field is not getting added
- what do kubernetes fluentbit logs say?
- aha! the field name is different in kubernetes before it gets to lag analytics

Edit

- use `kubectl edit` to edit configmap directly on cluster
- use modify config in 03-config-map. this is using the field name before it is modified by log analytics

Restart

- use `kubectl delete` with label selector to delete multiple pods

Observe

- check kubernetes fluentbit logs first this time
- we see the new fields now!
- go to log analytics to double check logs
- the new fields are now in log analytics as well
