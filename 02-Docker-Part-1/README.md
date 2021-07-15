# Session 2: Docker Part 1

## Lab Resources

- For these labs, we will be using [GitHub Codespaces](https://github.com/features/codespaces). To setup Codespaces, see Lab 1, [Open with Codespaces](../01-Setup-Codespaces/README.md#open-with-codespaces).
- This is a `hands-on lab` and assumes familiarity with basic Docker. Please use the link(s) below for basic familiarity.
  - Intro to Docker: <https://docs.microsoft.com/en-us/dotnet/architecture/microservices/container-docker-introduction/>
- Dockerfile Reference: <https://docs.docker.com/engine/reference/builder/>
- Docker 101 [video walk through](https://msit.microsoftstream.com/video/7115a4ff-0400-85a8-5a90-f1eb80993e79?channelId=533aa1ff-0400-85a8-6076-f1eb81fb8468) (Microsoft Internal)

## Some basic docker commands

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

# notice nothing is running or created. This is due to the --rm flag
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

# make sure you're in this directory!
pwd

```

### Build the `jumpbox`

We are going to build the jumpbox manually - later we'll show how to build using a `Dockerfile` which is the preferred method

```bash

# install some utilities into the alpine base image
# --name - names our container, jumpbox
# apk ... is the command we want to run in the container
docker run -it --name jumpbox alpine /bin/sh -c "apk add --no-cache curl redis mariadb-client py-pip jq nano bash && pip3 install --upgrade pip setuptools httpie"

# our container is created but not running
docker ps -a

# copy a very basic .profile into the jumpbox container
docker cp .profile jumpbox:/root

# set the image to use bash and start in /root
# commit (save) as an image with an additional layer
docker commit -c 'CMD ["/bin/bash", "-l"]'  -c 'WORKDIR /root' jumpbox jumpbox

# our jumpbox image is created
docker images

# remove jumpbox container
docker rm jumpbox

# let's run our new image
docker run -it --name jumpbox jumpbox

# your prompt changes again

# run a command
http www.microsoft.com

# exit back to Codespaces
exit

# Notice that jumpbox is stopped
docker ps -a

# set jumpbox to run forever (almost)
# Alpine doesn't support "sleep forever"
docker commit -c 'CMD ["/bin/bash", "-c", "sleep 999999999d"]'  jumpbox jumpbox

# remove jumpbox container
docker rm jumpbox

# run jumpbox detached
# -d runs in detached (daemon) mode
# compared to -it which runs in interactive tty mode
# --restart always will restart the docker image on reboot or failure
docker run -d --name jumpbox --restart always jumpbox

# run a command "in" jumpbox
docker exec -it jumpbox http www.microsoft.com

# notice the -t gives us ansi colors
docker exec jumpbox http www.microsoft.com

```

### Build jumpbox from `Dockerfile`

```bash

# remove jumpbox container without stopping first
docker rm -f jumpbox

# remove image
docker rmi jumpbox
docker images

# make sure you're in this directory
pwd

# build image from Dockerfile
docker build . -t jumpbox
docker images

# run jumpbox detached
docker run -d --name jumpbox --restart always jumpbox

# run a command "in" jumpbox
docker exec -it jumpbox http www.microsoft.com

# run a shell in jumpbox
docker exec -it jumpbox bash -l

# exit container
exit

```
