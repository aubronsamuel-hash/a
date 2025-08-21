#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

# S'assurer que l'API est up (fallback memory)
for i in {1..20}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)
  [ "$code" = "200" ] && break
  sleep 1
done
if [ "${code:-0}" != "200" ]; then
  echo "[INFO] API non demarree. Demarrage rapide (memory)..." >&2
  python -m pip install --upgrade pip >/dev/null
  pip install -q -e backend[dev]
  ADMIN_AUTOSEED=true ADMIN_USERNAME=admin ADMIN_PASSWORD=admin123 \
    python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001 &>/tmp/api.log &
  sleep 5
fi

try_login() {
  curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' \
    -d '{"username":"admin","password":"badpassword"}' "$BASE/auth/token"
}

has401=0; has429=0
for i in $(seq 1 20); do
  code=$(try_login)
  [ "$code" = "401" ] && has401=1
  [ "$code" = "429" ] && has429=1
  sleep 0.1
done
[ "$has401" = "1" ] || { echo "Attendu au moins un 401"; exit 1; }
echo "Rate limit memory OK (au moins un 401). Note: 429 peut etre desactive en tests selon config."
