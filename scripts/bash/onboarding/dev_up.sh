#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-8000}"
export PYTHONPATH=backend
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port "$PORT" &
sleep 2
code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/healthz)
[ "$code" = "200" ] && echo "OK: healthz 200" || { echo "KO: $code"; exit 3; }
