# Session 3: Docker Network Lab

> Purpose: TODO

This is a `hands-on lab` and assumes familiarity with basic Docker. Please use the links below for basic familiarity.

## Docker Introduction

- Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>
- Intro to Docker Best Practices: <https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/>
- Dockerfile Linter: <https://github.com/hadolint/hadolint>

## Lab Introduction

- For these labs, we will be using [GitHub Codespaces](https://github.com/features/codespaces)

> TODO [MS Internal Link to Stream Walkthrough](https://msit.microsoftstream.com/group/f36284b8-cb9d-42b4-947e-9ac3e141aa74?view=highlights)

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
