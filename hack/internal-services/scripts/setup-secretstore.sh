#!/bin/bash

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check if vault is installed
if ! command -v vault &> /dev/null; then
    echo "Error: vault is not installed or not in PATH"
    echo "Please install vault from: https://developer.hashicorp.com/vault/downloads"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    echo "Please install kubectl from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if jq is installed (used for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed or not in PATH"
    echo "Please install jq from: https://jqlang.github.io/jq/download/"
    exit 1
fi

echo "✓ vault is installed: $(vault version)"
echo "✓ kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "✓ jq is installed: $(jq --version)"

echo ""
echo "Setting up secret store for konflux-release-internal-services-approle"
echo "You need to have the /teams/stonesoup/roles/stonesoup-vault-all.yml role as in:"
echo "- https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/stonesoup/users/shebert.yml?ref_type=heads#L17"
echo ""

export VAULT_ADDR=https://vault.devshift.net
export VAULT_TOKEN=$(vault login -format=json -method=oidc | jq -r .auth.client_token | tail -1)

#vault kv get --format=json stonesoup/approles/konflux-release-internal-services-approle | jq -r '.data.data | to_entries[] | select(.key | IN("role_id", "secret_id")) | "\(.key): \(.value)"'
secret_id=$(vault kv get --format=json stonesoup/approles/konflux-release-internal-services-approle | jq -r '.data.data.secret_id')

tmp_file=$(mktemp)
cat <<EOF > ${tmp_file}
kind: Secret
apiVersion: v1
metadata:
  name: konflux-release-internal-services-vault
  namespace: stonesoup-int-srvc
stringData:
  secret-id: ${secret_id}
EOF

echo "Creating secret: "
kubectl create -f ${tmp_file}
rm ${tmp_file}
