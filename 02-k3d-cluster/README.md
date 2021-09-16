# Lab 2: k3d Cluster

## Lab Introduction

- For this lab, we will use [GitHub Codespaces](https://github.com/features/codespaces) and [k3d](https://k3d.io/) to create a `Development Cluster`
- For `production clusters` please see the [AKS documentation](https://docs.microsoft.com/en-us/azure/aks/)

> EXCUTE ALL COMMANDS IN THE `k8-quickstart` DIRECTORY

## Create a k3d Cluster

Verify k3d was installed on your Codespace

```bash
k3d --version
```

Create a k3d cluster and deploy the NGSA stack

```bash
make all
```

## Verify k3d Cluster

### Use `make` to check the endpoints of pods in the cluster

```bash
make check
```

```bash
# Output should be similiar

# curl all of the endpoints
0.5.0-0905-0604

2.1.0-0905-0604

<a href="/graph">Found</a>.

<a href="/login">Found</a>.
```

### Use `Docker` to check the cluster

```bash
docker ps
```

```bash
# Output should list similar IMAGE and NAMES for the running containers
IMAGE                                 NAMES
docker.io/rancher/k3d-proxy:4.4.8     k3d-k3s-default-serverlb
docker.io/rancher/k3s:v1.21.3-k3s1    k3d-k3s-default-server-0
docker.io/library/registry:2          k3d-registry.localhost
```

### Use `kubectl` to check pods are running and ready

View available `kubectl` aliases from devcontainer

```bash
alias | grep kubectl
```

```bash
# Output should be similar
alias k='kubectl'
alias kaf='kubectl apply -f'
alias kccc='kubectl config current-context'
alias kcgc='kubectl config get-contexts'
alias kdelf='kubectl delete -f'
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'
alias kj='kubectl exec -it jumpbox -- bash -l'
alias kje='kubectl exec -it jumpbox -- '
alias kl='kubectl logs'
```

Display pods

-A, --all-namespace: Lists requested object(s) across all namespaces

```bash
k get pods -A
```

```bash
# Output should be similar
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   local-path-provisioner-5ff76fc89d-mvbhk   1/1     Running   0          17m
kube-system   metrics-server-86cbb8457f-6nx79           1/1     Running   0          17m
kube-system   coredns-7448499f4d-t26fv                  1/1     Running   0          17m
monitoring    prometheus-deployment-5b6d588fdb-ns7nc    1/1     Running   0          17m
monitoring    grafana-64b848bdf9-vns5p                  1/1     Running   0          17m
default       ngsa-memory                               1/1     Running   0          17m
logging       fluentbit                                 1/1     Running   0          17m
default       webv                                      1/1     Running   0          16m
default       jumpbox                                   1/1     Running   0          16m
```

### Use `httpie` to check various `ngsa-app` endpoints

Check the `ngsa-app` version endpoint

```bash
http localhost:30080/version
```

```bash
# Output should be similar
HTTP/1.1 200 OK
Content-Type: text/plain
Date: Sun, 05 Sep 2021 07:30:44 GMT
Server: Kestrel
Transfer-Encoding: chunked

0.5.0-0905-0604
```

Check the `ngsa-app` healthz/ietf endpoint

```bash
http localhost:30080/healthz/ietf

# Output should have a header with 200 OK status
```

### Use `VS Code REST Client` to check various `ngsa-app` and `webvalidate` endpoints

- Open [curl.http](../curl.http) in VS Code
- Click on one or more of the `Send Request` links

## Run Load Test on `ngsa-app`

Use `make` to run a load test.

```bash
make test
# This uses `webvalidate` to run a load test.
# webv --verbose --summary tsv --server http://localhost:30080 --files baseline.json
# The exposed port on the ngsa-memory pod is mapped to  nodePort 30080.
```

## Port Forwarding

Codespaces can forward ports so that you can access from your local browser. We have the following ports fowarded:

Port | Service
---- | -------
30000 | Prometheus
30080 | NGSA application
30088 | WebV
32000 | Grafana (login u:admin/p:akdc-512)

- Click on the `Ports` tab in Codespaces to forward the ports
- Hover the cursor on a link in the `Local Address` column
- Select the globe icon

## Delete the Cluster

```bash
make delete
```

## Further Learning

- Explore the [Makefile](../Makefile)
- Explore the YAML files in the [deploy directory](../deploy)
