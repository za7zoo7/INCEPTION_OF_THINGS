#!/bin/bash

# Clean up all Kubernetes resources (if needed)
# Uncomment the following lines if you want to delete all Kubernetes resources and k3d clusters.
# echo "Cleaning up Kubernetes resources..."
kubectl delete all --all
# echo "Deleting all k3d clusters..."
k3d cluster delete --all

# Ensure the user is in the 'docker' group
# if ! groups | grep -q docker; then
#   echo "You are not in the 'docker' group. Please add yourself and restart the session."
#   exit 1
# fi

# Create a Kubernetes Cluster (named 'iot-cluster')
echo "Creating a Kubernetes cluster..."
k3d cluster create iot-cluster --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 1 --kubeconfig-update-default --kubeconfig-switch-context
if [ $? -ne 0 ]; then
  echo "Failed to create Kubernetes cluster."
  exit 1
fi
echo "Kubernetes cluster created successfully."

# Set up ArgoCD
echo "Setting up ArgoCD..."
kubectl get ns argocd || kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
if [ $? -ne 0 ]; then
  echo "ArgoCD server did not become ready in time."
  exit 1
fi

# Print ArgoCD initial password
echo "ArgoCD password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

kubectl get ns gitlab || kubectl create ns gitlab
kubectl apply -n gitlab -f home/CorrectionMachine/iot/bonus/confs/gitlab-config.yml


# script must wait for confirmation from the user before proceeding
read -p "Press enter to continue"

# Set up the 'dev' namespace and deploy the application
echo "Setting up the 'dev' namespace and deploying application..."
kubectl get ns dev || kubectl create ns dev
kubectl apply -n dev -f /home/CorrectionMachine/iot/bonus/confs/appconfig.yml

# Optionally, wait for the application pod to be ready
# kubectl wait --for=condition=Ready pod -l app=wil-playground -n dev --timeout=300s

echo "Setup complete."

kubectl port-forward svc/argocd-server -n argocd 8080:443 &
kubectl port-forward svc/wil-playground -n dev 8888:80 &

echo "You can access the ArgoCD UI at http://localhost:8080"
echo "You can access the wil-playground at http://localhost:8888"