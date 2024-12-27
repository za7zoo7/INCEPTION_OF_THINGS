#!/bin/bash

# This script installs docker, k3d and kubectl if not installed

#install docker if not installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  echo 'Installing docker'
  sudo curl -fsSL https://get.docker.com | bash
  sudo usermod -aG docker $USER
  sudo systemctl start docker
  sudo systemctl enable docker
else
  echo 'docker is installed'
fi

#install k3d if not installed
if ! [ -x "$(command -v k3d)" ]; then
  echo 'Error: k3d is not installed.' >&2
  echo 'Installing k3d'
  curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
else
  echo 'k3d is installed'
fi

#install kubectl if not installed
if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  echo 'Installing kubectl'
  sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
  sudo chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
else
  echo 'kubectl is installed'
fi

#create alias for kubectl
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc