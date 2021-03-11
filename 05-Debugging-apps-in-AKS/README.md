# K8s Commands for troubleshooting  

## Nodes

```bash
# Get basic Node information.
# This will tell us if our nodes are running. 
kubectl get nodes

# NAME                                STATUS   ROLES   AGE     VERSION
# aks-nodepool1-39674077-vmss000000   Ready    agent   4d18h   v1.19.7

# The Status column tell us that our node is ready.

```

## Deployments

```bash
# Get basic Deployments information.
# This will tell us if our Deployments are running. 
kubectl get deployments 

# NAME     READY   UP-TO-DATE   AVAILABLE   AGE
# logapp   0/6     0            0           16m

# The Ready column tell us that our deployment did not create any pods.
# The Ready column shows 0 out of 6 pods are ready.

# Get more detail information about the Deployment.
kubectl describe deployments <deployment name>

# ...
# Conditions:
#   Type             Status  Reason
#   ----             ------  ------
#   Available        False   MinimumReplicasUnavailable
#   ReplicaFailure   True    FailedCreate
#   Progressing      False   ProgressDeadlineExceeded
# ...

# By inspecting different Condition Status entries we can see multiple errors.
# One of the entries refers to Replica Failure.

# Edit Deployment on the cluster.
kubectl edit deployments <deployment name>

# This will let you edit and apply changes directly on the cluster.

# You can use different editors.
KUBE_EDITOR=nano kubectl edit deployments <deployment name> 

# Scaling up or down deployment 
kubectl scale deployment --replicas=<desired number of replicas> <deployment name>

# ...
# deployment.apps/logapp scaled
# ...

# Scale command will allow you to scale up or down the deployment  

```

## Configmaps

```bash
# Get basic Configmaps information.
# This will list the ConfigMaps
kubectl get configmap 

# NAME            DATA   AGE
# logapp-config   1      136m

# The Age column tell us how old is the configuration.


# Get more detail information about the Deployment.
kubectl describe configmap <configmap name>

# ...
# Data
# ====
# SLEEP_SECONDS:
# ----
# 0
# Events:  <none>

# By inspecting Data section we see that Slepp_Seconds is set to zero.
# There are no Events listed


# Edit Deployment on the cluster.
kubectl edit configmap <configmap name>

# This will let you edit and apply changes directly on the cluster.

```


## ReplicaSets

```bash
# Get basic ReplicaSet information.
# This will tell us if our ReplicaSets are running. 
kubectl get replicaset 

# NAME                DESIRED   CURRENT   READY   AGE
# logapp-84cbb6cf9d   6         0         0       35m

# The Desired, Current and Ready columns also show that 0 out of 6 pod are ready.

# Get more detail information about the ReplicaSet.
kubectl describe replicaset <replicaset name>

# ...
# Conditions:
#   Type             Status  Reason
#   ----             ------  ------
#   ReplicaFailure   True    FailedCreate

# Events:
#   Type     Reason        Age                   From                   Message
#   ----     ------        ----                  ----                   -------
#   Warning  FailedCreate  2m50s (x20 over 41m)  replicaset-controller  Error creating: admission webhook "validation.gatekeeper.sh" denied the request: [denied by azurepolicy-container-limits-c4ddc46a808c66825438] container <logapp> has no memory limit
# [denied by azurepolicy-container-limits-c4ddc46a808c66825438] container <logapp> cpu limit <1> is higher than the maximum allowed of <500m>
# ...

# By inspecting the Condition Status section we see the same replica failure entry.
# Now the replicaset description includes Event entries that provide more information about the replicaset error.

```

## Pods

```bash
# Get basic Pods information.
# This will tell us if our Pod are running. 
kubectl get pods 


# NAME                      READY   STATUS             RESTARTS   AGE
# logapp-66c48cb45d-4cswv   0/1     CrashLoopBackOff   9          28m
# logapp-66c48cb45d-gwmc7   0/1     CrashLoopBackOff   10         28m
# logapp-66c48cb45d-jhdc7   0/1     CrashLoopBackOff   9          25m
# logapp-66c48cb45d-lf6pf   0/1     CrashLoopBackOff   10         28m
# logapp-66c48cb45d-rkfxv   0/1     CrashLoopBackOff   9          28m

# The Ready, Status and Restarts columns indicates that no pods are running and also show that are on CrashLoopBackOff status.


# Get logs from a Pod information.
kubectl logs <pod name> 

# --sleep must be > 0
# ...


# By inspecting logs we can identify an error message related to app parameters.

```




## Helpful links

<https://docs.microsoft.com/en-us/azure/aks/troubleshooting>

<https://github.com/feiskyer/kubernetes-handbook/blob/master/en/troubleshooting/index.md>

<https://kubernetes.io/docs/tasks/debug-application-cluster/troubleshooting>

<https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application>

<https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster>

<https://kubernetes.io/docs/reference/kubectl/cheatsheet/>
