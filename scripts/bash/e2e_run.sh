#!/usr/bin/env bash
set -euo pipefail
: "${APP_ENV:=ci}"
: "${ADMIN_AUTOSEED:=true}"
: "${ADMIN_USERNAME:=admin}"
: "${ADMIN_PASSWORD:=admin123}"
[ -f .env ] || cp .env.example .env

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

# Preferer un navigateur systeme si present
CHROME="$(./scripts/bash/find_chrome.sh 2>/dev/null || true)"
if [ -n "$CHROME" ]; then
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  export CHROMIUM_EXECUTABLE="$CHROME"
fi

# Si aucun navigateur et pas telecharge: tenter install; sinon SKIP local
if [ -z "${CHROMIUM_EXECUTABLE:-}" ]; then
  if ! npx playwright browsers ls | grep -qi chromium; then
    set +e
    npx playwright install chromium
    rc=$?
    set -e
    if [ $rc -ne 0 ] && [ "${CI:-}" != "true" ]; then
      echo "Aucun navigateur et installation impossible -> E2E SKIP local." >&2
      export E2E_SKIP=1
    elif [ $rc -ne 0 ]; then
      echo "Installation navigateurs impossible en CI -> FAIL." >&2
      exit 1
    fi
  fi
fi

# Lancer E2E
( cd web && npm run build && npx playwright test )
