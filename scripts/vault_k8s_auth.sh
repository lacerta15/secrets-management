#!/usr/bin/env bash
# Configure Vault Kubernetes authentication
VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
SA_JWT=$(kubectl get secret $(kubectl get sa vault-auth -o jsonpath='{.secrets[0].name}' 2>/dev/null)     -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null || echo "")
K8S_CA=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d)
K8S_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

vault auth enable kubernetes 2>/dev/null || true
vault write auth/kubernetes/config     token_reviewer_jwt="$SA_JWT"     kubernetes_host="$K8S_HOST"     kubernetes_ca_cert="$K8S_CA"

# Create policy
vault policy write sysadmin - << 'EOF'
path "secret/data/cloudera-cm" { capabilities = ["read"] }
path "secret/data/hive-db"     { capabilities = ["read"] }
path "secret/data/k8s/*"       { capabilities = ["read","list"] }
EOF

# Create role
vault write auth/kubernetes/role/sysadmin     bound_service_account_names=vault-auth     bound_service_account_namespaces=default     policies=sysadmin     ttl=1h
echo "✅ Kubernetes auth configured"
