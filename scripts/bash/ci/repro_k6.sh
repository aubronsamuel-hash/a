#!/usr/bin/env bash
set -euo pipefail
PYTHONPATH=backend nohup python -m uvicorn backend.app.main:app --host 127.0.0.1 --port 8000 >/dev/null 2>&1 &
sleep 2
docker run --rm -e BASE_URL="http://127.0.0.1:8000" -v "$PWD":/work -w /work grafana/k6 run scripts/k6/smoke.js
