#!/usr/bin/env bash
set -euo pipefail
cd web
npm ci
npx playwright install --with-deps
echo "Playwright OK"
