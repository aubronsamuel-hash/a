#!/usr/bin/env bash
set -euo pipefail
cd web
npm ci

# Retry downloads (reseau instable). Installe uniquement Chromium pour nos tests.
for i in 1 2 3; do
  if npx playwright install chromium --with-deps; then
    echo "Playwright Chromium installe."
    exit 0
  fi
  echo "Retry playwright install ($i/3)..." >&2
  sleep 3
done
echo "Echec installation Chromium apres 3 tentatives." >&2
exit 1
