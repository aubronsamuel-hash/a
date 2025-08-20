#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

USER=${ADMIN_USERNAME:-admin}
PASS=${ADMIN_PASSWORD:-admin123}

curl -sf "$BASE/healthz" >/dev/null
TOKEN=$(curl -sf -H "Content-Type: application/json" -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" "$BASE/auth/token" | python -c 'import sys, json; print(json.load(sys.stdin)["access_token"])')

if [ -z "$TOKEN" ]; then
  echo "No token received" >&2
  exit 1
fi

curl -sf -H "Authorization: Bearer $TOKEN" "$BASE/auth/me" >/dev/null
echo "Smoke auth OK"
