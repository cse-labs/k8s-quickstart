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

## View All Pods

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

## Search Pods

```bash
# Enabled search with a forward slash
/
```

Now you can filter log entries by searched string

```bash
# Search for `ngsa`
🐩 > ngsa
# Press ENTER
```

Should only display pods with `ngsa` in the visible details.

## Pod Logs

```bash
# Use arrow keys to make sure the `ngsa-memory` pod is highlighted
```

The context commands in the header contains commands to view a pod's logs

- `<l> Logs`
- `<p> Logs Previous`

```bash
# Display `ngsa-memory` (pod) logs
l
```

The context commands in the header contains commands to configure the log view

- `<s> Toggle AutoScroll`
- `<f> Toggle FullScreen`
- `<t> Toggle Timestamp`
- `<w> Toggle Wrap`

```bash
# Toggle wrap on to view the entirety of each log entry
w
```

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

```bash
# Press ESC to exit search
# Press ESC again to exit logs

# Show search
/
# Delete previously entered characters `ngsa`
# Press ENTER
```


## View Pods in a Namespace

```bash
# View namespaces on system
:namspace
# Press ENTER

# Use arrow keys to highlight the `default` namespace
# Press ENTER
```

Now only pods in the default namespace are listed.

## Describe a Pod

This is useful in debugging

```bash
# Use arrow keys to highlight the pod name, `jumpbox`
```

The context commands in the header contains the command `<d>` to describe a pod

```bash
# Describe the `jumpbox`
d
```

Scavenger Hunt! Find the following information:

- IP Address
- Namespace
- Pod arguments that ran at execution
- Name of image used in container
- Events on pod

```bash
# Press ESC again to exit describe
```

## View Services

```bash
# View cluster services
:service
# Press ENTER
```

The context commands in the header contains the command `<d>` to describe a service

```bash
# Use arrows to highlight the `ngsa-memory` service
# Describe the service, `ngsa-memory`
d
```

Savenger Hunt! Find the `Port` to use in the [Open a Shell in a Pod](#open-a-shell-in-a-pod) section

```bash
# Press ESC to exit describe
```

## Open a Shell in a Pod

```bash
# View Pods
:pod
# Press ENTER

# Use arrow keys to highlight `jumpbox`
```

The context commands in the header contains the command `<s>` to open a shell in the container

```bash
# Open a shell in `jumpbox`
s

# List contents of folder
ls

# Hit the NodePort for ngsa-memory
http ngsa-memory:REPLACE_WITH_THE_PORT_FOUND_IN_THE_PREVIOUS_SECTION/version
# Validate 200 status

# Exit container
exit
```

## View secrets

```bash
# View secrets
:secret
# Press ENTER

# Use arrow keys to highlight the secret, `log-secrets` 
#Press ENTER
```

Scavenger Hunt! Find the following information:

- What is the size of the SharedKey secret?
- What is the size of the WorkspaceId secret?

```bash
# Exit out of describe
# Press ESC
```

The context commands in the header contains the command `<x>` to decode a secret

```bash
# Make sure `log-secrets` is still highlighted
# View decoded secrets
x
```

With `kubectl` commands, would typically need to convert from base64 to get the original string

```bash
# Exit out of Secret Decoder
# Press ESC
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
