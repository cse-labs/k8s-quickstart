# Fluent Bit - Azure Log Analytics

> Setup Fluent Bit and Azure Log Analytics

This is an end-to-end walkthrough of setting up Fluent Bit for log forwarding to Azure Log Analytics

The sample application generates JSON logs. Normal logs are written to stdout. Error logs are written to stderr.

```json

{"date":"2020-12-28T21:19:06.1347849Z","statusCode":200,"path":"/log/app","duration":78,"value":"HWIkixicjA"}
{"date":"2020-12-28T21:19:06.1444807Z","statusCode":500,"path":"/log/app","duration":266,"message":"Server error 9750"}
{"date":"2020-12-28T21:19:06.1613873Z","statusCode":200,"path":"/log/app","duration":34,"value":"olJDPKglhr"}
{"date":"2020-12-28T21:19:06.1660308Z","statusCode":200,"path":"/log/app","duration":86,"value":"lHldzimJSW"}
{"date":"2020-12-28T21:19:06.1669528Z","statusCode":200,"path":"/log/app","duration":65,"value":"BkPCTxoWcp"}
{"date":"2020-12-28T21:19:06.1846021Z","statusCode":400,"path":"/log/app","duration":9,"message":"Invalid paramater: cMwyFA"}
{"date":"2020-12-28T21:19:06.1867848Z","statusCode":200,"path":"/log/app","duration":82,"value":"BAZeQzaLFc"}
{"date":"2020-12-28T21:19:06.1944765Z","statusCode":200,"path":"/log/app","duration":22,"value":"NuUnKjZoNq"}
{"date":"2020-12-28T21:19:06.2080865Z","statusCode":200,"path":"/log/app","duration":74,"value":"wKOBoeYgBc"}
{"date":"2020-12-28T21:19:06.2116748Z","statusCode":200,"path":"/log/app","duration":79,"value":"UQWDWTPbHr"}

```

## Prerequisites

- Bash shell (tested on GitHub Codespaces, Mac, Ubuntu, WSL2)
- Azure CLI ([download](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest))
- Kubernetes cluster
  - Setup an [AKS Cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)
  - Setup a [Development Cluster](https://github.com/retaildevcrews/akdc) on an Azure VM
- kubectl with access to the Kubernetes cluster
- Docker CLI (optional) ([download](https://docs.docker.com/install/))
- Visual Studio Code (optional) ([download](https://code.visualstudio.com/download))

## Clone this repo

```bash

git clone https://github.com/retaildevcrews/k8s-quickstart
cd 04-Logging-FluentBit-LogAnalytics

```

## Deploy to Kubernetes

```bash

# verify k8s access
kubectl get all

# create service account
kubectl apply -f account.yaml

# apply the fluentbit config
kubectl apply -f 1-config.yaml

# start fluentbit pod
kubectl apply -f fluentbit-pod.yaml

# check pods until fluentb is Running
kubectl get pods

# check fluentb logs
kubectl logs fluentb

# run log app - this will generate 5 log entries
kubectl apply -f logapp.yaml

# check pods
# logapp will run and then exit with Completed state
kubectl get pods

# check fluentb logs
kubectl logs fluentb

# looking for a line like:
#   [2021/01/02 21:54:19] [ info] [output:azure:azure.0]

# check Log Analytics for your data
# this can take 10-15 minutes

# generate more logs
kubectl delete -f logapp.yaml
kubectl apply -f logapp.yaml

# check Log Analytics for your data
# this should only take a few seconds

# delete the app
kubectl delete -f logapp.yaml

# check pods
kubectl get pods

# Result - fluentb pod is running

```

## Create Azure Log Analytics Workspace

### Select Azure Subscription

```bash

# login to Azure (if necessary)
az login

# get list of subscriptions
az account list -o table

# select subscription (if necesary)
az account set -s YourSubscriptionName

```

### Create Log Analytics Workspace

```bash

# add az cli extension
#   this extension is in preview
az extension add --name log-analytics

# set environment variables (edit if desired)
export LogAppLoc=westus2
export LogAppRG=LogAppRG
export LogAppName=LogAppLogs

# create resource group
az group create -n $LogAppRG -l $LogAppLoc

# create Log Analytics Workspace
# check for workspace name is not unique error
#    export LogAppName with a different name and try again
az monitor log-analytics workspace create -g $LogAppRG -n $LogAppName -l $LogAppLoc

# add Log Analytics secrets
# check for secrets already exist error
#   kubectl delete secret fluentbit-secrets
kubectl create secret generic fluentbit-secrets \
  --from-literal=WorkspaceId=$(az monitor log-analytics workspace show -g $LogAppRG -n $LogAppName --query customerId -o tsv) \
  --from-literal=SharedKey=$(az monitor log-analytics workspace get-shared-keys -g $LogAppRG -n $LogAppName --query primarySharedKey -o tsv)

# verify the secrets are set properly (base 64 encoded)
kubectl get secret fluentbit-secrets -o jsonpath='{.data}'

```

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Microsoft Contributor License Agreement](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).

For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments

## Trademarks

This project may contain trademarks or logos for projects, products, or services.

Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).

Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.

Any use of third-party trademarks or logos are subject to those third-party's policies.
