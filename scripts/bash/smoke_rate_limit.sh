#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

try_login() {
  curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' \
    -d '{"username":"admin","password":"badpassword"}' "$BASE/auth/token"
}

has_401=0
has_429=0
for i in $(seq 1 20); do
  code=$(try_login)
  [ "$code" = "401" ] && has_401=1
  [ "$code" = "429" ] && has_429=1
  sleep 0.1
done
[ "$has_401" = "1" ] || { echo "Attendu au moins un 401"; exit 1; }
[ "$has_429" = "1" ] || { echo "Attendu au moins un 429 (limite atteinte)"; exit 1; }
echo "Rate limit OK (401 puis 429)"
