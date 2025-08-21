#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-8000}"
pkill -f "uvicorn .*--port $PORT" || true
echo "OK: backend stoppe"
