# Lab 3: k9s

## Lab Introduction

- For this lab, we will use [GitHub Codespaces](https://github.com/features/codespaces) and [k3d](https://k3d.io/) to create a `Development Cluster`
- To manage the cluster, we will use [k9s](https://k9scli.io/), which provides a Kubernetes CLI
- For `production clusters` please see the [AKS documentation](https://docs.microsoft.com/en-us/azure/aks/)

> EXCUTE ALL COMMANDS IN THE `k8-quickstart` DIRECTORY

## Create a k3d Cluster

Re-create a k3d cluster and re-deploy the NGSA stack from the previous lab

```bash
make all
```

## View Pods

```bash
# Start k9s
k9s
```

- The header is divided into 3 columns: Kubernetes Details, Context Commands, k9s Logo
- The body initially displays the default namespace pods in the cluster
- The context commands in the header contain 2 commands
  - `<0> all`
  - `<1> default`

```bash
# Display all pods regardless of namespace
0
```

## View Logs

```bash
# Use arrow keys to highlight the pod named, ngsa-memory
```

- The context commands in the header contains commands to view a pod's logs
  - `<l> Logs`
  - `<p> Logs Previous`

```bash
# Display ngsa-memory (pod) logs
l
```

- The context commands in the header contains commands to configure the log view
  - `<s> Toggle AutoScroll`
  - `<f> Toggle FullScreen`
  - `<t> Toggle Timestamp`
  - `<w> Toggle Wrap`

```bash
# Toggle wrap on to view the entirety of each log entry
w
```

## Search Logs

```bash
# Enabled search with a forward slash
/
```

Now you can filter log entries by searched string

```bash
# Search for log entries with `movies`
🐩 > movies
```

The searched string should have a different font color than the rest of the log entry text.

## Close Logs

```bash
# Press ESC to exit search
# Press ESC again to exit logs
```

## View Services

```bash
# To view another resource use `:NAME_OF_RESOURCE` then press ENTER

# View cluster services
:services
# Press ENTER
```

## Exit k9s

```bash
# Exit k9s
:q
# Press ENTER
```

## Delete the Cluster

```bash
make delete
```

## Further Learning

- Explore the [Makefile](../Makefile)
- Explore the YAML files in the [deploy directory](../deploy)
