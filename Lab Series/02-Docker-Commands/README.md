# Session 2: Docker Commands Lab

> Purpose: TODO

This is a `hands-on lab` and assumes familiarity with basic Docker. Please use the links below for basic familiarity.

## Docker Introduction

- Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>
- Intro to Docker Best Practices: <https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/>
- Dockerfile Linter: <https://github.com/hadolint/hadolint>

## Lab Introduction

- For these labs, we will be using [GitHub Codespaces](https://github.com/features/codespaces)

> TODO [MS Internal Link to Stream Walkthrough](https://msit.microsoftstream.com/group/f36284b8-cb9d-42b4-947e-9ac3e141aa74?view=highlights)

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
# commit (save) as an image with an additional layer
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

### Build jumpbox from `Dockerfile`

- TODO - build jumpbox from a dockerfile
