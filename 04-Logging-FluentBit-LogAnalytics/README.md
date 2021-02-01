# Fluent Bit - Azure Log Analytics

> Setup Fluent Bit and Azure Log Analytics

This is an end-to-end walkthrough of setting up Fluent Bit for log forwarding to Azure Log Analytics

The sample application generates JSON logs. Normal logs are written to stdout. Error logs are written to stderr.

Sample logs from logapp

```json

{
    "date":"2020-12-28T21:19:06.1347849Z",
    "statusCode":200,
    "path":"/log/app",
    "duration":78,
    "value":"HWIkixicjA"
},

{
    "date":"2020-12-28T21:19:06.1846021Z",
    "statusCode":400,
    "path":"/log/app",
    "duration":9,
    "message":"Invalid paramater: cMwyFA"
},

{
    "date":"2020-12-28T21:19:06.1444807Z",
    "statusCode":500,
    "path":"/log/app",
    "duration":266,
    "message":"Server error 9750"
}

```

## Prerequisites

- Bash shell (tested on GitHub Codespaces, Mac, Ubuntu, WSL2)
- Kubernetes Dev Cluster
  - Setup a [Development Cluster](https://github.com/retaildevcrews/akdc) on an Azure VM
- Visual Studio Code (optional) ([download](https://code.visualstudio.com/download))

## Verify your dev cluster

```bash

# ssh into your dev cluster

# verify k8s access
kubectl get all

# verify the k8s cluster is using containerd
kubectl describe node k8s | grep containerd

# You should see:
# Container Runtime Version:  containerd://x.x.x

# if you see dockerd as the runtime you have to uninstall docker, reboot, run kubeadm reset
# the logs depend on containerd and will not work with dockerd

```

## Clone this repo

```bash

git clone https://github.com/retaildevcrews/k8s-quickstart
cd 04-Logging-FluentBit-LogAnalytics

```

## Deploy to Kubernetes

```bash

# create service account
kubectl apply -f account.yaml

# add temporary secrets
kubectl create secret generic fluentbit-secrets \
  --from-literal=WorkspaceId=dev \
  --from-literal=SharedKey=dev

```

### Deploy basic Fluent Bit config

> repeat these steps for 1, 2 and 3-config.yaml

```bash

# apply the fluentbit config
kubectl apply -f 1-config.yaml

# start fluentbit pod
kubectl apply -f fluentbit-pod.yaml

# check fluentb logs
kubectl logs fluentb

# run log app - this will generate a log entry
kubectl apply -f logapp.yaml

# check pods
# logapp will run and then exit with Completed state
kubectl get pods

# check fluentb logs
kubectl logs fluentb

# compare to output section below

# delete the app
kubectl delete -f logapp.yaml

# delete fluent bit
kubectl delete -f fluentbit-pod.yaml

# check pods
# should be none
kubectl get pods

# Repeat with 2-config and 3-config

```

### Output

#### Output 1

```text

[0] kube.var.log.containers.logapp_default_app-*.log:
[
  # timestamp
  1612126313.650765701,
  {
    # log is a string field that contains json
    # it is not a json map
    "log"=>
    "{
        # log is a string field that contains json
        # it is not a map
        "log":
        "{
            \"date\":\"2021-01-31T20:51:50.8930226Z\",
            \"statusCode\":200,
            \"path\":\"/log/app\",
            \"duration\":78,
            \"value\":\"cNxwDdxRKX\"
        }",

        "stream":"stdout",
        "time":"2021-01-31T20:51:50.906665641Z"
    }"
  }
]

```

#### Output 2

```text

[0] kube.var.log.containers.logapp_default_app-*.log:
[
    1612135622.239024095, 
    {
        # log was converted to a json map by the kubernetes filter
        # Merge_Log  On
        "stream"=>"stdout",
        "logtag"=>"F", 

        "date"=>"2021-01-31T23:27:02.2260122Z", 
        "statusCode"=>200,
        "path"=>"/log/app", 
        "duration"=>41,
        "value"=>"rCepJlQqMC", 

        # added the kubernetes json properties
        "kubernetes"=>
        {
            "pod_name"=>"logapp", 
            "namespace_name"=>"default", 
            "pod_id"=>"83889e9a-9ee8-456a-a347-0513e89a5df0", 
            "labels"=>
            {
                "app"=>"logapp"
            },
            "host"=>"k8s", 
            "container_name"=>"app", 
            "docker_id"=>"aa89f*", 
            "container_hash"=>"docker.io/retaildevcrew/logapp@sha256:2e6ed*", 
            "container_image"=>"docker.io/retaildevcrew/logapp:latest"
        }
    }
]

```

#### Output 3

```text

[0] kube.var.log.containers.logapp_default_app-*.log:
[
    1612135739.551305142,
    {
        "stream"=>"stdout", 
        "logtag"=>"F", 

        "date"=>"2021-01-31T23:28:59.5368881Z", 
        "statusCode"=>200,
        "path"=>"/log/app", 
        "duration"=>79,
        "value"=>"EWyKyDRPwJ", 

        # "lifted" to top level properties with the next filters
        "kubernetes_pod_name"=>"logapp", 
        "kubernetes_namespace_name"=>"default", 
        "kubernetes_pod_id"=>"d1d65bbe-e658-4568-8412-e47d49d69540", 
        "kubernetes_host"=>"k8s", 
        "kubernetes_container_name"=>"app", 
        "kubernetes_docker_id"=>"f4ffa8*", 
        "kubernetes_container_hash"=>"docker.io/retaildevcrew/logapp@sha256:2e6ed*", 
        "kubernetes_container_image"=>"docker.io/retaildevcrew/logapp:latest", 
        "kubernetes_labels_app"=>"logapp", 

        # copied from kubernetes_* by the modify filter
        "k_container"=>"app", 
        "k_app"=>"logapp", 

        # added properties by the modify filter
        "Zone"=>"DevZone", 
        "Region"=>"DevRegion"
    }
]

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

# verify keys
az monitor log-analytics workspace show -g $LogAppRG -n $LogAppName --query customerId -o tsv
az monitor log-analytics workspace get-shared-keys -g $LogAppRG -n $LogAppName --query primarySharedKey -o tsv

# delete temporary secrets
kubectl delete secret fluentbit-secrets

# add Log Analytics secrets
kubectl create secret generic fluentbit-secrets \
  --from-literal=WorkspaceId=$(az monitor log-analytics workspace show -g $LogAppRG -n $LogAppName --query customerId -o tsv) \
  --from-literal=SharedKey=$(az monitor log-analytics workspace get-shared-keys -g $LogAppRG -n $LogAppName --query primarySharedKey -o tsv)

# verify the secrets are set properly (base 64 encoded)
kubectl get secret fluentbit-secrets -o jsonpath='{.data}'

```

### Deploy Fluent Bit config

```bash

# apply the fluentbit config
kubectl apply -f 4-config.yaml

# start fluentbit pod
kubectl apply -f fluentbit-pod.yaml

# check fluentb logs
kubectl logs fluentb

# run log app - this will generate a log every second
kubectl apply -f run-in-loop.yaml

# check pods
kubectl get pods

# check fluentb logs
kubectl logs fluentb

# looking for a line like:
#   [2021/02/01 21:54:19] [ info] [output:azure:azure.0]

# check Log Analytics for your data
# this can take 10-15 minutes the first time

# delete the app
kubectl delete -f run-in-loop.yaml

# delete fluent bit
kubectl delete -f fluentbit-pod.yaml

# check pods
kubectl get pods

```
