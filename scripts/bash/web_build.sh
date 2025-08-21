#!/usr/bin/env bash
set -euo pipefail
cd web
[ -d node_modules ] || npm ci
npm run build
cd ..
test -f web/dist/index.html || { echo "Build Vite introuvable (web/dist/index.html absent)"; exit 1; }
echo "Build front OK. Pour servir via backend:"
echo " FRONT_DIST_DIR=\"$(pwd)/web/dist\" python -m uvicorn app.main:app --app-dir backend --port 8001"
