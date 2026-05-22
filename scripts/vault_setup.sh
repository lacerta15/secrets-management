#!/usr/bin/env bash
# Install and initialize HashiCorp Vault
set -euo pipefail
VAULT_VERSION="${VAULT_VERSION:-1.15.0}"
echo "Setting up HashiCorp Vault $VAULT_VERSION..."

# Install
curl -sLO "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
unzip -o "vault_${VAULT_VERSION}_linux_amd64.zip" -d /usr/local/bin/
rm "vault_${VAULT_VERSION}_linux_amd64.zip"
chmod +x /usr/local/bin/vault

# Systemd service
useradd -r -s /sbin/nologin vault 2>/dev/null || true
mkdir -p /etc/vault /var/lib/vault
cat > /etc/vault/vault.hcl << 'EOF'
ui = true
storage "file" { path = "/var/lib/vault/data" }
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1   # enable TLS in production!
}
EOF

cat > /etc/systemd/system/vault.service << 'EOF'
[Unit]
Description=HashiCorp Vault
After=network.target
[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault/vault.hcl
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl enable --now vault
sleep 2

export VAULT_ADDR='http://127.0.0.1:8200'
echo "Initializing Vault..."
vault operator init -key-shares=5 -key-threshold=3 | tee /root/vault-init.txt
echo ""
echo "⚠️  SAVE /root/vault-init.txt SECURELY — contains unseal keys and root token!"
echo "Vault running at: http://localhost:8200"
