#!/bin/sh

# install WebV
dotnet tool install -g webvalidate

# copy our grafana dashboards
sudo cp deploy/grafana/grafana.db /grafana
sudo chown -R 472:472 /grafana
