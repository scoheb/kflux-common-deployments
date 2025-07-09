#!/bin/bash

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed or not in PATH"
    echo "Please install helm from: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    echo "Please install kubectl from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo "✓ helm is installed: $(helm version --short 2>/dev/null || helm version)"
echo "✓ kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

echo "Setting up local external secret operator"
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets   -n external-secrets   --create-namespace   --set installCRDs=true

echo "waiting for pods"
kubectl wait --for=condition=Ready pod --all -A
