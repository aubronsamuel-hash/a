#!/usr/bin/env bash
set -euo pipefail
cd web
npm ci
rm -f ../.e2e_skip.env

# 1) Tenter navigateur systeme
ROOT_DIR="$(cd .. && pwd)"
if "$ROOT_DIR/scripts/bash/find_chrome.sh" >/dev/null 2>&1; then
  echo "Navigateur systeme detecte, SKIP download (PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1)."
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  exit 0
fi

# 2) Telechargement Chromium (3 tentatives)
set +e
ok=0
for i in 1 2 3; do
  npx playwright install chromium --with-deps && ok=1 && break
  echo "Retry playwright install chromium ($i/3)..." >&2
  sleep 3
done
set -e
if [ "$ok" != "1" ]; then
  if [ "${CI:-}" = "true" ]; then
    echo "Echec installation Chromium (CI) -> FAIL" >&2
    exit 1
  else
    echo "Echec installation Chromium (local) -> E2E SKIP" >&2
    echo "E2E_SKIP=1" > ../.e2e_skip.env
    exit 0
  fi
fi

echo "Playwright Chromium installe."
