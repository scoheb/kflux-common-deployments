#!/bin/bash 

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Setting up namespace"
kubectl create namespace stonesoup-int-srvc
