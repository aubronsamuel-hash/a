#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

try_login() {
curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' \
-d '{"username":"admin","password":"badpassword"}' "$BASE/auth/token"
}

has401=0; has429=0
for i in $(seq 1 20); do
  code=$(try_login)
  [ "$code" = "401" ] && has401=1
  [ "$code" = "429" ] && has429=1
  sleep 0.05
done
[ "$has401" = "1" ] || { echo "Attendu au moins 1 reponse 401"; exit 1; }
[ "$has429" = "1" ] || { echo "Attendu au moins 1 reponse 429 (Redis)"; exit 1; }
echo "Rate limit Redis OK"

