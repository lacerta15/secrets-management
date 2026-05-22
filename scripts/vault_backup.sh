#!/usr/bin/env bash
VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:?Set VAULT_TOKEN}"
BACKUP_DIR="${BACKUP_DIR:-/backup/vault}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
echo "Backing up Vault snapshot..."
vault operator raft snapshot save "${BACKUP_DIR}/vault-${TIMESTAMP}.snap"
echo "✅ Vault snapshot: ${BACKUP_DIR}/vault-${TIMESTAMP}.snap"
ls -lh "$BACKUP_DIR/" | tail -5
