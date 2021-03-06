# Docker and Kubernetes Lab

> 100 level

This is a `hands-on lab` and assumes familiarity with basic Docker and Kubernetes concepts. Please use the links below for basic familiarity.

## Docker Introduction

- Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>
- Intro to Docker Best Practices: <https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/>
- Dockerfile Linter: <https://github.com/hadolint/hadolint>

## Kubernetes Introduction

- TODO - add k8s for kids video
- TODO - other links

## Session 1

### Setup Codespaces

- For these labs, we will be using [GitHub Codespaces](https://github.com/features/codespaces) and [KIND](https://kind.sigs.k8s.io/) to create a `Development Cluster`
- For `production clusters` please see the [AKS documentation](https://docs.microsoft.com/en-us/azure/aks/)

- setup codespace
- validate docker / kubectl / etc
- show how to configure
- show how to delete
- show how to suspend
- show restarting

## Session 2

### Some basic docker commands

```bash

# see which containers are running (none)
docker ps

# see which containers are created (none)
docker ps -a

# show local images (none)
docker images

# pull an image
docker pull ubuntu
docker images

# let's run the image interactively
# -i - interactivee
# -t - tty
# --rm - remove the container on exit
docker run -it --rm ubuntu

# notice your prompt changed to something like this: root@257fde9a1ad2:/#
# we are now "in" the docker container

# run some commands
ls -alF
pwd

exit

# back in the codespaces terminal

# notice nothing is running or created
docker ps -a

```

### Create a `jumpbox` image

- A `jumpbox` is a machine with dual network homes that allows you to `jump` from one network to the other
- In this case, it will allow us to `jump` into the Docker network
- A `jumpbox` is invaluable for debugging issues

> We are going to use `Alpine` as the base for our jump box because it is signifcantly smaller than most other images

```bash

# pull the alpine image
docker pull alpine

# notice the size difference between alpine and ubuntu
docker images

```

### Build the `jumpbox`

We are going to build the jumpbox manually - later we'll show how to build using a `Dockerfile` which is the preferred method

```bash

# install some utilities into the alpine base image
# notice that we name our image jumpbox
# apk ... is the command we want to run in the container
docker run -it --name jumpbox alpine apk add --no-cache curl redis mariadb-client httpie jq nano bash

# our container is created but not running
docker ps -a

# copy a very basic .profile
docker cp 01-Docker101/.profile jumpbox:/root

# set the image to use bash and start in /root
# commit (save) as an image
docker commit -c 'CMD ["/bin/bash", "-l"]'  -c 'WORKDIR /root' jumpbox jumpbox

# our jumpbox image is created
docker images

# remove container
docker rm jumpbox

# let's run our new image
docker run -it --name jumpbox jumpbox

# your prompt changes again

# exit back to Codespaces
exit

# Notice that jumpbox is stopped
docker ps

docker ps -a

# set jumpbox to run forever (almost)
# Alpine does support "sleep forever"
docker commit -c 'CMD ["/bin/bash", "-c", "sleep 999999999d"]'  jumpbox jumpbox

# remove jumpbox
docker rm jumpbox

# run jumpbox detached
# -d runs in detached (daemon) mode
# compared to -it which runs in interactive tty mode
# --restart always will restart the docker image on reboot or failure
docker run -d --name jumpbox --restart always jumpbox

# run a command "in" jumpbox
docker exec -t jumpbox http www.microsoft.com

# notice the -t gives us ansi colors
docker exec jumpbox http www.microsoft.com

```

### Run a simple web app in Docker

```bash

# run a simple web app
# pull from GitHub container registry (ghcr.io/retaildevcrews)
# use the beta tag (:beta)
# pass the --in-memory flag to the container
docker run -d --name web ghcr.io/retaildevcrews/ngsa-app:beta --in-memory

# see what happened
docker ps
docker logs web

# run a command in the container
docker exec -t web ls -al

```

### Create a Docker network

- Currently, the `jumpbox` can't communicate with the `web server`
- In order for this to work, you have to create a `Docker network` and add each container to the network

```bash

# this will fail
docker exec -t jumpbox http web:8080/version

# create a network
docker create network web

# add containers to network
docker network connect web jumpbox
docker network connect web web

# this will work
docker exec -t jumpbox http web:8080/version

```

### Accessing web server from terminal

- Currently, we can only access `web` from `jumpbox`
- Docker allows you to map ports from within docker

```bash

# delete the web server
docker rm -f web

# create the web server
# add to the web network
# map port 8080 in the container to port 80 in the terminal
docker run -d --name web -p 80:8080 --network web ghcr.io/retaildevcrews/ngsa-app:beta --in-memory

# check web from jumpbox
docker exec -t jumpbox http web:8080/version

# check web from terminal
# notice that our port mapping mapped the port to 80 locally
http localhost/version

```

### Access from your local browser

`Codespaces` can `forward` local ports so you can access remotely

- Click on the `PORTS 4` tab
- Choose `Add Port`
- Enter 80
- Hover over `Local Address` for `Port 80` and click `Open in Browser`
- You will get a new browser tab with the `Swagger UI`
  - Note: popup blockers may have to be disabled

### Remove the web container

```bash

docker rm web

# oops - the container is still running, so we need to stop it first
docker stop web

# we can restart it
docker start web
http localhost/version
docker logs web

# stop and remove
docker stop web
docker rm web

# you could do this instead
docker rm -f web

# only jumpbox should show
docker ps -a

```

## Session 3

- Install kind (make create)
- Load local jumpbox image into Kind
- Create jumpbox pod
- k exec command in jumpbox
- run ngsa-app as pod
- delete ngsa-app
- show http in jumpbox

## Session 4

- explain pods and deployments
- re-deploy ngsa-app

## Session 5

- Services
- Cluster IP
- NodePort
- Show accessing ngsa-app locally via NodePort
- I would save Load Balancer for a later discussion for simplicity

## Session 6

- deploy LodeRunner (k apply -f)
- LodeRunner uses the cluster IP
- show logs / traffic
- access /version via NodePort
- show /metrics on app / loderunner

## Session 7

- deploy Prometheus (k apply -f)
- show Prometheus via NodePort (30000)

## Session 8

- deploy Grafana
- show Grafana dashboards via NodePort (32000)
  - admin
  - Ngsa512

## Session 9

- deploy Fluent Bit
- show logs
- show logs via k9s

## Session 10

- makefile
- make all
- delete loderunner (k delete -f)
- make create
- check loderunner logs in k9s

## Session 11

- build LodeRunner local
- clone repo
- docker build
- load local image into kind
- k delete -f loderunner
- k apply -f loderunner-local
- check logs in k9s / Grafana

## Session 12

- run a load test
- show grafana dashboard
- show grafana annotation

## Build a container

> At the end of the first section, we said there was a better way to build images ...

### Build a docker container

- TODO - change this to build jumpbox or loderunner

### Let's run MariaDB in a container

- TODO - should we cut this because we're running ngsa-app / loderunner?

```bash

### TODO - change this to loderunner?

# start the server
# use -e to specify an environment variable
docker run -d --name maria -e MYSQL_ROOT_PASSWORD=SuperSecretPassword mariadb

docker ps

# start a client
# --link creates a link to the server container
# --rm removes the container when it exits
# sh -c ... runs the mysql CLI with the right parameters
docker run -it --link maria:svr --rm jumpbox sh -c 'exec mysql -h svr -uroot -pSuperSecretPassword'

# from the MariaDB prompt
# MariaDB [(none)]>
show databases;
exit;

docker ps -a

# notice the MySQL client container is gone (--rm)

```
