#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:8000}"
METRICS_PATH="${2:-/metrics}"
curl -s "$BASE_URL/healthz" >/dev/null
curl -s -D - -o /dev/null "$BASE_URL$METRICS_PATH" | grep -E "200|text/plain"
