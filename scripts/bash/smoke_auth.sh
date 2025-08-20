#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

USER=${DEV_USER:-admin}
PASS=${DEV_PASSWORD:-admin123}

echo "== HEALTH =="
curl -sf "$BASE/healthz" | jq -r '.status,.version' >/dev/null

echo "== LOGIN =="
TOKEN=$(curl -sf -H "Content-Type: application/json" -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" "$BASE/auth/token" | jq -r '.access_token')
test -n "$TOKEN"

echo "== /auth/me =="
curl -sf -H "Authorization: Bearer $TOKEN" "$BASE/auth/me" | jq -r '.username' >/dev/null

echo "== /debug/secret =="
curl -sf -H "Authorization: Bearer $TOKEN" "$BASE/debug/secret" | jq -r '.secret' >/dev/null
echo "Smoke auth OK"

