#!/bin/sh

apt-get update
apt-get install -y --no-install-recommends git curl httpie

# pull the docker images we use
docker pull ubuntu
docker pull golang
docker pull mariadb
docker pull redis
docker pull retaildevcrew/govote
docker pull retaildevcrew/goweb
