#!/bin/sh

# add kubectl completion
mkdir -p ~/.local

## TODO - move this to base image
cp .devcontainer/kubectl_completion ~/.local/kubectl_completion

## TODO - move this to base image
## TODO - add dotnet tools to path
# install WebV
dotnet tool install -g webvalidate

# update .bashrc with helpful aliases
echo "" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc

echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kga='kubectl get all'" >> ~/.bashrc
echo "alias kgaa='kubectl get all --all-namespaces'" >> ~/.bashrc
echo "alias kaf='kubectl apply -f'" >> ~/.bashrc
echo "alias kdelf='kubectl delete -f'" >> ~/.bashrc
echo "alias kl='kubectl logs'" >> ~/.bashrc
echo "alias kccc='kubectl config current-context'" >> ~/.bashrc
echo "alias kcgc='kubectl config get-contexts'" >> ~/.bashrc
echo "alias kje='kubectl exec -it jumpbox -- '" >> ~/.bashrc

echo "export GO111MODULE=on" >> ~/.bashrc
echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> ~/.bashrc
echo 'export PIP=$(ipconfig | tail -n 1)' >> ~/.bashrc

## TODO - remove this once in base image
echo 'source $HOME/.local/kubectl_completion' >> ~/.bashrc

echo 'complete -F __start_kubectl k' >> ~/.bashrc

export PATH=$PATH:$HOME/.local/bin

### Application specific configuration
### Delete if reusing for other projects

## TODO - move this to base image
# create prometheus directory
sudo mkdir -p /prometheus
sudo chown -R 65534:65534 /prometheus

# copy grafana.db to /grafana
sudo mkdir -p /grafana
sudo  chown -R 472:472 /grafana

## TODO - copy grafana.db and chown
