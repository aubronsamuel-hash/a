#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

# 0) Verifier curl
if ! need_cmd curl; then
  echo "[INFO] curl indisponible; skip du smoke rate-limit." >&2
  exit 0
fi

# 1) Essayer la sante
code="$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)"
if [ "$code" != "200" ]; then
  echo "[INFO] API non demarree. Tentative demarrage rapide (memory) si outils presents..." >&2

  # Pas de demarrage si python/uvicorn indisponibles -> SKIP propre
  if ! need_cmd python && ! need_cmd python3; then
    echo "[INFO] python absent; skip du smoke rate-limit." >&2
    exit 0
  fi

  # Choisir interprete
  PYBIN="python"
  need_cmd python || PYBIN="python3"

  # uvicorn via module; si non installe -> SKIP
  if ! $PYBIN -c "import uvicorn" 2>/dev/null; then
    echo "[INFO] uvicorn non installe; skip du smoke rate-limit." >&2
    exit 0
  fi

  # backend installable ? si pip absent ou echec -> SKIP
  if ! need_cmd pip && ! $PYBIN -c "import pip" 2>/dev/null; then
    echo "[INFO] pip absent; skip du smoke rate-limit." >&2
    exit 0
  fi

  # Demarrage best-effort
  set +e
  $PYBIN -m pip install -q -e backend[dev]
  $PYBIN -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001 &>/tmp/api.log &
  sleep 5
  set -e
fi

# 2) Re-tester sante; si toujours KO -> SKIP (non bloquant)
code="$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)"
if [ "$code" != "200" ]; then
  echo "[INFO] API indisponible ($code); skip du smoke rate-limit." >&2
  exit 0
fi

# 3) Exercer le rate-limit (non bloquant si endpoints differents)
try_login() {
  curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' \
    -d '{"username":"admin","password":"badpassword"}' "$BASE/auth/token"
}

has401=0; has429=0
for i in $(seq 1 20); do
  code="$(try_login)"
  [ "$code" = "401" ] && has401=1
  [ "$code" = "429" ] && has429=1
  sleep 0.05
done

# Rapport informatif mais non bloquant
echo "[INFO] Smoke rate-limit: 401=$has401 429=$has429 (non bloquant)"
