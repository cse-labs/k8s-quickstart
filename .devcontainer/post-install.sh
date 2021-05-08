#!/bin/sh

# install WebV (using the beta for testing)
# we can't install this in the base image
dotnet tool install -g --version 2.0.0-beta2 webvalidate

# copy our grafana dashboards
sudo cp deploy/grafana/grafana.db /grafana
sudo chown -R 472:472 /grafana

# clone the ocw-asb repo
git clone https://github.com/retaildevcrews/ocw-asb ../ocw-asb
sudo chown -R akdc:akdc ../ocw-asb
