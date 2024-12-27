#kubectl clean everything
kubectl delete all --all

#k3d clean everything
k3d cluster delete --all

#k3d create cluster
k3d cluster create iot-cluster --api-port 6443 --port 80:80@loadbalancer --port 443:443@loadbalancer --agents 1
export KUBECONFIG=$(k3d kubeconfig merge iot-cluster --kubeconfig-switch-context)
#k3d get kubeconfig
k3d kubeconfig get iot-cluster

#create namespace argocd and install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#wait for argocd-server pod to be running
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

#print argocd password
echo "ArgoCD password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

#create namespace dev
kubectl create namespace dev
kubectl apply -n dev -f appconfig.yml

#wait for dev-app pod to be running
kubectl wait --for=condition=Ready pod -l app=dev-app -n dev --timeout=300s

#port forward argocd-server service
kubectl port-forward svc/argocd-server -n argocd 8080:443


