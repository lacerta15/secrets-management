#!/usr/bin/env python3
"""Rotate credentials for Cloudera, databases, and other services.
Usage: python3 rotate_secrets.py --service cloudera-cm
"""
import argparse, secrets, string, os, yaml, json, urllib.request, base64
from datetime import datetime

CONFIG = os.path.join(os.path.dirname(__file__),'..','config','config.yml')

def random_password(length=24):
    chars = string.ascii_letters + string.digits + '!@#$%^&*'
    return ''.join(secrets.choice(chars) for _ in range(length))

def vault_write(addr, token, path, data):
    url = f"{addr}/v1/{path}"
    payload = json.dumps(data).encode()
    req = urllib.request.Request(url, data=payload,
          headers={'X-Vault-Token': token, 'Content-Type': 'application/json'},
          method='POST')
    urllib.request.urlopen(req, timeout=10)

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--service', required=True, choices=['cloudera-cm','hive-db','all'])
    p.add_argument('--vault-addr', default=os.environ.get('VAULT_ADDR','http://localhost:8200'))
    p.add_argument('--vault-token', default=os.environ.get('VAULT_TOKEN',''))
    p.add_argument('--dry-run', action='store_true')
    args = p.parse_args()

    services = ['cloudera-cm','hive-db'] if args.service == 'all' else [args.service]

    for svc in services:
        new_pass = random_password()
        print(f"[{datetime.now():%H:%M:%S}] Rotating password for: {svc}")
        if args.dry_run:
            print(f"  [DRY-RUN] Would set new password: {new_pass[:4]}***")
        else:
            if args.vault_token:
                vault_write(args.vault_addr, args.vault_token,
                           f"secret/data/{svc}",
                           {"data": {"password": new_pass, "rotated_at": datetime.now().isoformat()}})
                print(f"  ✅ Password stored in Vault at secret/data/{svc}")
            else:
                print(f"  ⚠️  VAULT_TOKEN not set — skipping Vault storage")
        print(f"  New password length: {len(new_pass)} chars")

if __name__ == '__main__': main()
