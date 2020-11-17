#!/bin/sh

# install WebV global tool
dotnet tool install -g webvalidate

# update .bashrc
echo "" >> ~/.bashrc
echo 'export PATH="$PATH:~/.dotnet/tools"' >> ~/.bashrc

docker pull ubuntu
docker pull mariadb
docker pull redis
docker pull retaildevcrew/govote
docker pull retaildevcrew/go-web-aks
