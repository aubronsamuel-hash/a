#!/usr/bin/env bash
set -euo pipefail
SUB="${1:-u-local}"; ROLES="${2:-user}"; SECRET="${3:-change_me}"; ALGO="${4:-HS256}"
python - "$SUB" "$ROLES" "$SECRET" "$ALGO" <<'PY'
import os, sys, jwt
sub, roles, secret, algo = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
roles_list = [r.strip() for r in roles.split(',') if r.strip()]
payload = {"sub": sub, "roles": roles_list}
print(jwt.encode(payload, secret, algorithm=algo))
PY
