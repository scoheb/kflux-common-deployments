#!/bin/bash


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Deploying staging internal services"
kubectl apply -k ${SCRIPT_DIR}/../../../components/internal-services/staging -n stonesoup-int-srvc
echo "retrying after 10 seconds"
sleep 10
kubectl apply -k ${SCRIPT_DIR}/../../../components/internal-services/staging -n stonesoup-int-srvc
echo "Waiting for pods"
kubectl wait --timeout=300s --for=condition=Ready pod --all -A
