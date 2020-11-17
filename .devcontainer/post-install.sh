#!/bin/sh

apt-get update
apt-get install -y --no-install-recommends git curl httpie

# install WebV global tool
dotnet tool install -g webvalidate

# update .bashrc
echo "" >> ~/.bashrc
echo 'export PATH="$PATH:~/.dotnet/tools"' >> ~/.bashrc

docker pull ubuntu
docker pull golang
docker pull mariadb
docker pull redis
docker pull retaildevcrew/govote
docker pull retaildevcrew/goweb
