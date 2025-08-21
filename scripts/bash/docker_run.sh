#!/usr/bin/env bash
set -euo pipefail
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker non installe." >&2
    echo "Fallback local :" >&2
    echo "  1) bash scripts/bash/web_build.sh" >&2
    echo "  2) FRONT_DIST_DIR=$(pwd)/web/dist python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001" >&2
    exit 0
fi
tag=ccapi:local
ctr=ccapi_local
docker rm -f "$ctr" >/dev/null 2>&1 || true
docker run -d --name "$ctr" -p 8001:8001 -e FRONT_DIST_DIR="/app/public" "$tag" >/dev/null
echo "Container lance: $ctr (http://localhost:8001)"
