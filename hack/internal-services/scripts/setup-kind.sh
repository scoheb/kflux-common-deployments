#!/bin/bash

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "Error: kind is not installed or not in PATH"
    echo "Please install kind from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    echo "Please install kubectl from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo "✓ kind is installed: $(kind version)"
echo "✓ kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

kind delete cluster
sleep 5
kind create cluster
sleep 5

kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
echo "waiting for pods"
kubectl wait --for=condition=Ready pod --all -A
#sleep 60
#oc get pods -A --no-headers | grep -vi running
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml
echo "waiting for pods"
kubectl wait --for=condition=Ready pod --all -A
#sleep 20

dashpid=$(ps -eawwf | grep "9097:9097" | grep -v grep | awk '{print $2}')
if [ ! -z "$dashpid" ] ; then
  kill -9 $dashpid
fi
sleep 2
kubectl --namespace tekton-pipelines --v=0 port-forward svc/tekton-dashboard 9097:9097 > /tmp/dashboard.log 2>&1 &

echo ""
echo "Dashboard is here: http://localhost:9097/#/namespaces/default/pipelineruns"

echo "Updating feature-flags"

kubectl get cm feature-flags -n tekton-pipelines -o yaml | \
  sed -e 's|disable-affinity-assistant: "false"|disable-affinity-assistant: "true"|' | \
  sed -e 's|enable-step-actions: "false"|enable-step-actions: "true"|' > /tmp/ff.yaml

kubectl apply -f /tmp/ff.yaml -n tekton-pipelines
