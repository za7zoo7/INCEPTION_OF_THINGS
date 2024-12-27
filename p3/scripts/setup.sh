#!/bin/bash

# This script installs docker, k3d and kubectl if not installed


# Install Docker if not installed
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker is not installed."
  echo "Installing Docker..."

  # Download and install Docker
  curl -fsSL https://get.docker.com | sudo bash

  # Add the current user to the Docker group
  sudo usermod -aG docker $USER

  #newgrp docker
  # Start and enable the Docker service
  sudo systemctl start docker
  sudo systemctl enable docker

  echo "Docker has been installed and the group change has been applied to this session."
else
  echo "Docker is already installed."
fi

#install k3d if not installed
if ! [ -x "$(command -v k3d)" ]; then
  echo 'k3d is not installed.'
  echo 'Installing k3d ...'
  curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | sudo bash
else
  echo 'k3d is installed'
fi

#install kubectl if not installed
if ! [ -x "$(command -v kubectl)" ]; then
  echo 'kubectl is not installed.'
  echo 'Installing kubectl ...'
  sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
  sudo chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
else
  echo 'kubectl is installed'
fi


# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# rm argocd-linux-amd64


#create alias for kubectl
echo "alias k='kubectl'" >> /home/correctionmachine/.bashrc
source /home/correctionmachine/.bashrc