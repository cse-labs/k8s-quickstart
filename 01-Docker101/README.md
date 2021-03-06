# Docker Walk Through

> 100 level

## Docker Introduction

- Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>

### Some basic docker commands

```bash

# show local images
docker images

# pull an image
### TODO - use alpine instead of ubuntu
### ash / sh don't work in codespaces
### output is not displayed

docker pull ubuntu
docker images

# let's run the image interactively
docker run -it --rm ubuntu

# notice your prompt changed to something like this: root@257fde9a1ad2:/#
# we are now "in" the docker container

# run some commands
ls -alF
pwd

exit

# back in the codespaces terminal
```

### Create a `jumbox` image

- A `jumbox` is a machine with dual network homes that allows you to `jump` from one network to the other
- In this case, it will allow us to `jump` into the Docker network

We are going to use `Alpine` as the base for our jump box because it is signifcantly smaller than most other distro images

```bash

# pull the alpine image
docker pull alpine

# notice the size difference between alpine and ubuntu
docker images

```


#### Build the `jumpbox`

```bash

# install some utilities into the alpine base image
docker run -it --name jumpbox alpine apk add --no-cache curl redis mariadb-client httpie jq nano bash

# copy a very basic .profile
docker cp 01-Docker101/.profile jumpbox:/root

# set the image to use bash and start in /root
docker commit -c 'CMD ["/bin/bash", "-l"]'  -c 'WORKDIR /root' jumpbox jumpbox

# remove build image
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
docker commit -c 'CMD ["/bin/bash", "-c", "sleep 999999999d"]'  jumpbox jumpbox

# remove jumpbox
docker rm jumpbox

# run jumpbox detached
docker run -d --name jumpbox --restart always jumpbox

# run a command "in" jumpbox
docker exec -t jumpbox http www.microsoft.com

# notice the -t gives us ansi colors
docker exec jumpbox http www.microsoft.com

# there's a MUCH better way to build Docker images. We'll get there soon.

```

### Run a simple web app in Docker

```bash

# run a simple web app
# todo - move to ghcr.io
docker run -d -p 80:8080 --name web ghcr.io/retaildevcrews/ngsa-app:beta --in-memory

# see what happened
docker ps
docker logs web

# send a request to the web server
http localhost/version

# recheck the logs
docker logs web

# run some commands in the container
docker exec -t web ls -al

```

### Remove the web container

```bash

docker rm web

# oops - the container is still running, so we need to stop it first
docker stop web

# we can restart it
docker start web
http localhost
docker logs web

# stop and remove
docker stop web
docker rm web

# you could do this instead
docker rm -f web

# only jumpbox should show
docker ps -a

```

## Build a container

> At the end of the first section, we said there was a better way to build images ...

### Build a docker container

- goweb is a simple web app written in Go
  - don't worry if you don't know anything about Go
    - you don't need to - the beauty of Dockerfiles!

```bash

### TODO - change this to build jumpbox

```

### Let's run MariaDB in a container

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

### Let's run something a little more complex

```bash

# run a Redis container
docker run -d --name redis redis

# restart the jumpbox container
docker start -ai jumpbox

ping redis

# oops
# We have to attach the containers to the same network
exit

# create the network
docker network create vote

# add the containers to the network
docker network connect vote maria
docker network connect vote redis
docker network connect vote jumpbox

# let's try again
docker start -ai jumpbox

ping -c 1 redis
ping -c 1 maria
ping -c 1 jumpbox

# let's connect to Redis
redis-cli -h redis

set Dogs 100
set Cats 3

# exit redis-cli
exit

# Run the mysql CLI
mysql -h maria -uroot -pSuperSecretPassword

show databases;
exit;

# exit the jumpbox
exit

# let's run a web app that talks to the redis cache
# notice we attach it to the network
docker run -d --net vote --name govote retaildevcrew/govote

docker start -ai jumpbox

http govote:8080

# Dogs RULE!

# exit the jump box
exit

```

### What if we want to access the website from our codespace

```bash

docker rm -f govote

# Same run command with -p option to expose the port
docker run -d --net vote --name govote -p 8080:8080 retaildevcrew/govote

http localhost:8080

# our network still works
docker start -ai jumpbox

http govote:8080

exit

# We can also access remotely from codespaces
# Click on "PORTS" tab in the terminal
# Click on Open in Browser (globe icon) in the 127.0.0.1:8080 port

# Dogs RULE!

```

### Container size matters

Notice the size difference in the diferent images - from 13 MB to 9.87 GB

The size of the image has a big impact on deployment time, so you want to minimize your image size. That typically also reduces your security footprint.

```bash

docker images

```

### Cleanup

```bash

docker rm -f govote
docker rm -f redis
docker rm -f maria
docker rm jumpbox

# remove unused images / networks
docker system prune -f

# check results
docker ps -a

```

## Additional Docker Resource Links

- Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>
- Intro to Docker Best Practices: <https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/>
- Dockerfile Linter: <https://github.com/hadolint/hadolint>
