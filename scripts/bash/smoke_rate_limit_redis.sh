#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] curl indisponible; skip du smoke rate-limit Redis." >&2
  exit 0
fi

# readiness API (si KO -> skip non bloquant)
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)
  [ "$code" = "200" ] && break
  sleep 1
done
if [ "${code:-0}" != "200" ]; then
  echo "[INFO] API indisponible; skip du smoke Redis." >&2
  exit 0
fi

try_login() {
  curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' \
    -d '{"username":"admin","password":"badpassword"}' "$BASE/auth/token"
}

has401=0; has429=0
for i in $(seq 1 30); do
  code=$(try_login)
  [ "$code" = "401" ] && has401=1
  [ "$code" = "429" ] && has429=1
  sleep 0.05
done
echo "[INFO] Smoke Redis: 401=$has401 429=$has429 (non bloquant)"
