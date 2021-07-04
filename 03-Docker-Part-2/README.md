# Session 3: Docker Part 2

## Lab Resources

- For these labs, we will be using [GitHub Codespaces](https://github.com/features/codespaces). To setup Codespaces, see Lab 1, [Open with Codespaces](../01-Setup-Codespaces/README.md#open-with-codespaces).
- This is a `hands-on lab` and assumes familiarity with basic Docker. Please use the link(s) below for basic familiarity.
  - Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>
- Dockerfile Reference: <https://docs.docker.com/engine/reference/builder/>
- Docker 101 [video walk through](https://msit.microsoftstream.com/video/7115a4ff-0400-85a8-5a90-f1eb80993e79?channelId=533aa1ff-0400-85a8-6076-f1eb81fb8468) (Microsoft Internal)

## Run a simple web app in Docker

```bash

# run a simple web app
# pull from GitHub container registry (ghcr.io/retaildevcrews)
# use the beta tag (:beta)
# pass the --in-memory and --prometheus flags to the container
docker run -d --name web ghcr.io/retaildevcrews/ngsa-app:beta --in-memory --prometheus

# see what happened
docker ps
docker logs web

# run a command in the container
docker exec -t web ls -al

```

## Create a Docker network

- Currently, the `jumpbox` can't communicate with the `web server`
- In order for this to work, you have to create a `Docker network` and add each container to the network

```bash

# Verify the jumpbox container from (Session 2: Docker Part 1)[../02-Docker-Part-1/README.md] is running
docker ps

# this will fail
docker exec -t jumpbox http web:8080/version

# create a network
docker network create web

# add containers to network
docker network connect web jumpbox
docker network connect web web

# this will work
docker exec -t jumpbox http web:8080/version

```

## Accessing web server from terminal

- Currently, we can only access `web` from `jumpbox`
- Docker allows you to map ports from within docker

```bash

# delete the web server
docker rm -f web

# create the web server
# add to the web network
# map port 8080 in the container to port 80 in the terminal
docker run -d --name web -p 80:8080 --network web ghcr.io/retaildevcrews/ngsa-app:beta --in-memory --prometheus

# check web from jumpbox
docker exec -t jumpbox http web:8080/version

# check web from terminal
# notice that our port mapping mapped the port to 80 locally
http localhost/version

```

## Access from your local browser

`Codespaces` can `forward` local ports so you can access remotely

- Click on the `PORTS` tab
- Hover over `Local Address` for `Port 80` and click `Open in Browser`
- You will get a new browser tab with the `Swagger UI`
  - Note: popup blockers may have to be disabled

## Generate web traffic

We use [Web Validate (WebV)](https://github.com/microsoft/webvalidate) to generate and validate API requests 7 x 24

```bash

# verify you're in this directory
pwd

# run WebV --help
docker run -it --rm ghcr.io/retaildevcrews/webvalidate --help

# run a "baseline" test
# -v mounts the current directory "into" the container
# -s is our webserver
# -f is the file in this directory
docker run -it --rm --net web -v $(pwd):/app/TestFiles ghcr.io/retaildevcrews/webvalidate -s http://web:8080 -f baseline.json

# check the web logs
docker logs web

# run 1 req/sec test
# -v mounts the current directory "into" the container
# --run-loop runs in a loop
# --sleep waits 1000ms between request
# --log-format json uses json logs
# --verbose displays all logs (not just failures)
# --prometheus exposes the Prometheus counters on /metrics
docker run -d --name webv --rm --net web -p 8080:8080 -v $(pwd):/app/TestFiles ghcr.io/retaildevcrews/webvalidate -s http://web:8080 -f baseline.json --run-loop --sleep 1000 --log-format json --verbose --prometheus

# check the webv logs a few times
docker logs webv

# check the web logs
docker logs web

# check the WebV Prometheus endpoint
http localhost:8080/metrics

# check the web prometheus endpoint
http localhost:8080/metrics

```

## Monitoring

- Both `web` and `WebV` log events to `json` which can be forwarded using `Fluent Bit` or `OMS Agent`
- Both `web` and `WebV` expose Prometheus counters via the `/metrics` endpoint
- This allows you to build a `single pane of glass` that monitors the `server` responses (web) and the `client` responses (WebV)
  - This helps in debugging local network issues especially in `Kubernetes` or `AKS`
  - You can use `Azure Monitor` or `Graphana` for the dashboards (as well as other options)

## Remove the WebV container

```bash

docker rm webv

# oops - the container is still running, so we need to stop it first
docker stop webv

# we can restart it
docker start webv

# may take a moment for WebV to start
http localhost:8080/version
docker logs webv

# stop and remove
docker stop webv
docker rm webv

```

## Remove the web container

```bash

# stop and remove
docker stop web
docker rm web

# you could do this instead
docker rm -f web

# only jumpbox should be running
docker ps -a

```
