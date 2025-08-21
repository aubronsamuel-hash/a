#!/usr/bin/env bash
set -euo pipefail
cd web
npm ci

# 1) Tenter navigateur systeme
ROOT_DIR="$(cd .. && pwd)"
if "$ROOT_DIR/scripts/bash/find_chrome.sh" >/dev/null 2>&1; then
  echo "Navigateur systeme detecte, SKIP download (PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1)."
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  exit 0
fi

# 2) Telechargement Chromium (3 tentatives)
set +e
for i in 1 2 3; do
  npx playwright install chromium --with-deps && ok=1 && break
  echo "Retry playwright install chromium ($i/3)..." >&2
  sleep 3
done
set -e
if [ "${ok:-0}" != "1" ]; then
  if [ "${CI:-}" = "true" ]; then
    echo "Echec installation Chromium (CI) -> FAIL" >&2
    exit 1
  else
    echo "Echec installation Chromium (local) -> E2E SKIP" >&2
    exit 0
  fi
fi

echo "Playwright Chromium installe."
