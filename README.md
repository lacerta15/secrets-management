# secrets-management
HashiCorp Vault setup, secrets rotation, and integration with Cloudera/Kubernetes.

## Scripts
| Script | Purpose |
|--------|---------|
| `scripts/vault_setup.sh` | Initialize and configure Vault |
| `scripts/rotate_secrets.py` | Rotate credentials for all services |
| `scripts/vault_k8s_auth.sh` | Configure Vault Kubernetes auth |
| `scripts/vault_backup.sh` | Backup Vault data |
