#!/bin/sh

mkdir -p ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/id_rsa
chmod 700 ~/.ssh/id*

sudo apt-get update
sudo apt-get install -y --no-install-recommends git curl httpie
