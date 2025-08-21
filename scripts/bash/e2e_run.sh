#!/usr/bin/env bash
set -euo pipefail
: "${APP_ENV:=ci}"
: "${ADMIN_AUTOSEED:=true}"
: "${ADMIN_USERNAME:=admin}"
: "${ADMIN_PASSWORD:=admin123}"
if [ ! -f .env ]; then cp .env.example .env; fi

# Demarrer backend si necessaire
set +e
code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/healthz)
set -e
if [ "$code" != "200" ]; then
  python -m pip install --upgrade pip >/dev/null
  pip install -q -e backend[dev]
  python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001 &>/tmp/api.log &
  sleep 5
fi

# Tenter auto-install chromium si absent
if ! npx playwright browsers ls | grep -qi chromium; then
  npx playwright install chromium || true
fi

# Lancer E2E
( cd web && npm run build && npx playwright test )
