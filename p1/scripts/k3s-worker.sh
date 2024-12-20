#!/bin/bash
# Get the master node's IP from the arguments
MASTER_IP=$1

# Get the token from the shared folder
TOKEN=$(cat /vagrant/token)

# Install K3s agent (worker) and join the master node
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--node-ip 192.168.42.111" K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -