#!/bin/sh

# install WebV
# we can't install this in the base image
dotnet tool install -g webvalidate

sudo  cp grafana.db /grafana
sudo  chown -R 472:472 /grafana
