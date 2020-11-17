# Docker Walk Through
### 100 level

### Additional Docker Resource Links
* Intro to Docker Best Practices: <https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/>
* Dockerfile Linter: <https://github.com/hadolint/hadolint>

### Setup

If you haven't already, clone the repo and run setup as explained in the [readme](README.md)

### Connect to your build server

Follow the steps in [readme](README.md) to connect to your build server via SSH

Your prompt should look like this:

aks@docker:~/$

### Some basic docker commands

```

# show local images
docker images

# pull an image
docker pull alpine
docker images

# let's run the image interactively as a "jump box"
docker run -it --name jbox ubuntu

# notice your prompt changed to something like this: root@257fde9a1ad2:/#
# we are now "in" the docker container

pwd
cd root

ping www.microsoft.com

# oops - ping isn't installed
# let's install ping, curl and some other goodies
apt-get update
apt-get install -y iputils-ping curl wget nano git redis-tools mariadb-client

ping -c 1 www.microsoft.com
curl www.microsoft.com

exit

```

### We don't want to have to do that every time ...

```

# save our changes to a new image
docker commit jbox jumpbox
docker images

# let's run our new image
docker run -it --name jbox jumpbox

# oops
docker ps -a

# we have to remove the instance first
docker rm jbox
docker run -it --name jbox jumpbox

# your prompt changes again
# we're in the root directory (/) and we want to start in the home directory (~)
exit

# tell docker where to start
docker commit -c "WORKDIR /root" jbox jumpbox

# remove the instance and run again
docker rm jbox
docker run -it --name jbox jumpbox

# from the docker container

pwd

exit

# See what's there
docker ps

docker ps -a

# there's a MUCH better way! We'll get there soon.

```


### Run a simple web app in Docker

```

# run a simple web app
docker run -d -p 80:8080 --name web fourco/go-web-aks

# see what happened
docker ps
docker logs web

# send a request to the web server
curl localhost

# recheck the logs
docker logs web

# run some commands in the container
docker exec web ls -al
docker exec web cat logs/app.log

# start an interactive shell in the container
docker exec -it web sh

# notice your prompt changed

# run a couple of commands and exit
ls -al
cat logs/app.log

exit

```

### Remove the web container

```

docker rm web

# oops - the container is still running, so we need to stop it first
docker stop web

# we can restart it
docker start web
curl localhost
docker logs web

# stop and remove
docker stop web
docker rm web

# you could do this instead
docker rm -f web

# only jbox should show
docker ps -a

```

## Build a container

At the end of the first section, we said there was a better way to build images ...

### Clone a sample Go app

```

cd ~
git clone https://github.com/4-co/go-web-aks
cd go-web-aks

```

### Build the docker container

```

docker build -t web .

# look at what happened
docker images

# notice the size difference in the web container and the <none> container

# let's see what we told Docker to do
# notice these commands are very similar to the first section
cat dockerfile

```

### Run the container

```

docker run -d --name web -p 80:8080 web

# verify it's running
docker ps

# send a web request and look at logs
curl localhost
docker logs web

```

### Stop and remove the web container

```

docker stop web
docker rm web

# only the jumpbox should show
docker ps -a

```

### Let's run MariaDB in a container

```

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
create database logs;
use logs;
show tables;
exit;

docker ps -a

# notice the MySQL client container is gone (--rm)

```


### Let's run something a little more complex ...

```

# run a Redis container
docker run -d --name redis redis

# restart the jbox container
docker start -ai jbox

ping redis

# oops
# We have to attach the container to the same network
# We could also use --link redis:redis
exit

# create the network
docker network create vote

# add the containers to the network
docker network connect vote maria
docker network connect vote redis
docker network connect vote jbox

# let's try again
docker start -ai jbox

ping -c 1 redis
ping -c 1 maria
ping -c 1 jbox

# let's connect to Redis
redis-cli -h redis

set Dogs 100
set Cats 3

incr Dogs
decr Cats

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
docker run -d --net vote --name govote fourco/govote

docker start -ai jbox

curl govote:8080

# Dogs RULE!

# exit the jump box
exit

```

### What if we want to curl the website from our dev server?

```
docker rm -f govote

# Same run command with -p option to expose the port
docker run -d --net vote --name govote -p 80:8080 fourco/govote

curl localhost

# our network still works
docker start -ai jbox

curl govote:8080

# Dogs RULE!

```

### Pull an image from ACR

The ACR section of the k8s walkthrough demonstrates how to create a Service Principal with access for docker / kubectl

Note: the ID / Password should be stored in Key Vault, not a public repo ...

```
# oops
docker pull fourco.azurecr.io/acrgoweb

# Have to login with a Service Principal
docker login  -u 24046c70-b4b2-4c06-b62d-52f27d8f1974 -p 3b1ee421-3dc7-48dd-b097-874cd37ec4e3 fourco.azurecr.io

# Works
docker pull fourco.azurecr.io/acrgoweb

docker images

```

### Container size matters

Notice the size difference in the diferent images - from 12 MB to 700 MB

The size of the image has a big impact on deployment time, so you want to minimize your image size. That typically also reduces your security footprint. In the walkthrough, we used bad docker build practices but you have to start somewhere ...

```

docker images

```

### Cleanup

```

# if you don't remove these, parts of the AKS walk through will break as the ports will be in use
docker rm -f govote
docker rm -f redis
docker rm -f maria
docker rm jbox

# check results
docker ps -a

```

## We're done!
