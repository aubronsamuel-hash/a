#!/usr/bin/env bash
set -euo pipefail
: "${APP_ENV:=ci}"
: "${APP_LOG_LEVEL:=info}"
: "${ADMIN_AUTOSEED:=true}"
: "${ADMIN_USERNAME:=admin}"
: "${ADMIN_PASSWORD:=admin123}"
: "${JWT_SECRET:=ci-secret}"
: "${JWT_ALGO:=HS256}"
: "${JWT_TTL_SECONDS:=3600}"
: "${CORS_ENABLE:=true}"
: "${CORS_ALLOW_ORIGINS:=http://localhost:3000,http://localhost:5173}"
: "${DB_DSN:=sqlite:///./cc.db}"
python -m pip install --upgrade pip >/dev/null
pip install -q -e backend[dev]
python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001 &>/tmp/api.log &
sleep 5
code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/healthz || true)
echo "healthz=$code"
test "$code" = "200"
