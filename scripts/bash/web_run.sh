#!/usr/bin/env bash
set -euo pipefail
cd web
VITE_API_BASE_URL="${VITE_API_BASE_URL:-http://localhost:8001}" npm run dev &>/tmp/web.log & disown
sleep 3
echo "Frontend http://localhost:5173"
