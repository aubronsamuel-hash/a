#!/usr/bin/env bash
set -euo pipefail
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker non installe. Fallback: bash scripts/bash/web_build.sh && python -m uvicorn app.main:app --app-dir backend" >&2
    exit 0
fi
tag=ccapi:local
docker build -t "$tag" .
echo "Image construite: $tag"
