# Deploying Pods Walk Through

> 100 level

## Kubernetes Introduction

- Overview of Kubernetes: <https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/>

## Installations

- Install minikube to start a local Control Plane: <https://minikube.sigs.k8s.io/docs/start/>
- Install Kubernetes command-line tool, kubectl: <https://kubernetes.io/docs/tasks/tools/>

## Alias Setup

```bash

# Helpful aliases for common kubectl commands
alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias kl='kubectl logs'
alias kf='kubectl logs fluentb'

```

## Manually Creating Pods

> Execute commands from directory, `k8s-quickstart/02-Deploying-Pods101`

```bash

# Start local control plane
minikube start

# Check to see if any pods are running
k get pods

# Notice there should be no pods running

# Manually create a pod from PodSpec, nginx-pod.yaml
k create -f nginx-pod.yaml

# Now, let's verify that pod, nginx, is running
k get pods

```

## Manually Create ReplicaSet

Pods are ephemeral, and when we manually create a pod, there is no controller to watch and maintain the desired number of pods. A ReplicaSet will use label selectors to identify the pods it manages and maintain the desired number of pods.

> Execute commands from directory, `k8s-quickstart/02-Deploying-Pods101`

```bash

# Get pod name
k get pods

# Delete manually create pod by name
k delete pod nginx

# Manually create ReplicaSet from spec, nginx-replicaset.yaml
k create -f nginx-replicaset.yaml

# Verify ReplicaSet
k get rs

# Verify 3 pods where created by the ReplicaSet
# and copy the name of one of the pods
k get pods

# Delete one of the pods by name
k delete pod <pod_name>

# Verify that ReplicaSet creates another pod to maintain desired state
k get pods


```

## Deployments

By using Deployments to create ReplicaSets, we have access to rollout and rollback functionality. With each new Deployment, the Deployment controller will create a new ReplicaSet with the updated specs and scale down existing ReplicaSets. It will identify which ReplicaSets to delete via matching label selectors and differing templates.

You may see something called ReplicationControllers. It is recommended to use ReplicaSets and Deployments, which form the replacement for ReplicationControllers.

### Using Deployments to Create ReplicaSets

> Execute commands from directory, `k8s-quickstart/02-Deploying-Pods101`

```bash

# Get ReplicaSet name
k get rs

# Delete ReplicaSet by name
k delete rs nginx

# Create Deployment
ka nginx-deployments.yaml --record=true

# Verify Deployment, ReplicaSet, and Pods
k get deployments && k get rs && k get pods

```

### Rollout Deployment

There are several ways to rollout a new verion of a Deployment. This lab covers the preferred approach, updating the Deployment spec file and then applying it.

> Execute commands from directory, `k8s-quickstart/02-Deploying-Pods101`

```bash

# Open nginx-deployment.yaml in a text editor

# Update the nginx version in nginx-deployment.yaml on line 18
# Old specs
- image: nginx:1.12
# Updated specs
- image: nginx:1.13
# Save file

# Apply the new Deployment spec
ka nginx-deployment.yaml --record=true

# Verify creation of new ReplicaSet and pods
# Verify scale down of old ReplicaSet and pods
k get deployments && k get rs && k get pods

```

### Rollback Deployment

> Execute commands from directory, `k8s-quickstart/02-Deploying-Pods101`

```bash

# Get Deployment name
k get deployments

# View Deployment rollout history by name
k rollout history deployments nginx

# View Deployment detail for revision 2
k rollout history deployments nginx --revision=2

# Rollback Deployment by name
k rollout undo deployment nginx

```

## Kubernetes Services Inside the Cluster

Pods are ephemeral. When a pod dies and replicates, the pod is assigned a new private IP address, which is only accessible inside the cluster.

> Execute commands from directory, `k8s-quickstart/02-Deploying-Pods101`

```bash

# Get Deployment name
k get deployments

# Delete Deployment by name
k delete deployment nginx

# Open nginx-service-and-deployment.yaml in text editor

# View the targetPort in nginx-service-and-deployment.yaml on line 34
# The service will send its requests to the targetPort
# The pod and container application will be listening on the targetPort

# Create the Deployment and Service
k create -f nginx-service-and-deployment.yaml

# View Services and copy the CLUSTER-IP address for the service, nginx
# Notice that ClusterIP is the default service type
k get services

# Create a BusyBox pod in the cluster to hit the ClusterIP
# BusyBox is a very small image with several utilities
# BusyBox is useful for cluster development and testing
k run busybox --image busybox --image busybox -- /bin/sh -c "wget -qO- http://<cluster_ip>:80" --restart never

# Verify nginx response from pod application via BusyBox log
kl busybox

```

## Additional Kubernetes Resource Links

- Overview of Kubernetes Components: <https://kubernetes.io/docs/concepts/overview/components/>
- Template for PodSpecs: <https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#podtemplate-v1-core/>
