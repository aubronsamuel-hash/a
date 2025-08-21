#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

# Verifier disponibilite API avec retries
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)
  [ "$code" = "200" ] && break
  sleep 1
done
if [ "${code:-0}" != "200" ]; then
  echo "[ERROR] API indisponible ($code). Demarrez le stack Redis: bash scripts/bash/compose_up_redis.sh" >&2
  echo "[TIP ] Sans Docker, utilisez le fallback memory: bash scripts/bash/smoke_rate_limit.sh" >&2
  exit 1
fi

try_login() {
  curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' -d '{"username":"admin","password":"badpassword"}' "$BASE/auth/token"
}

has401=0; has429=0
for i in $(seq 1 30); do
  code=$(try_login)
  [ "$code" = "401" ] && has401=1
  [ "$code" = "429" ] && has429=1
  sleep 0.05
done

[ "$has401" = "1" ] || { echo "[ERROR] Attendu au moins 1 reponse 401"; exit 1; }
[ "$has429" = "1" ] || { echo "[ERROR] Attendu au moins 1 reponse 429 (Redis)"; exit 1; }
echo "[OK] Rate limit Redis OK"
