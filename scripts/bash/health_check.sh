#!/usr/bin/env bash
set -euo pipefail
BASE="${1:-http://localhost:8001}"
echo "Check $BASE/livez ..."
curl -sf "$BASE/livez" >/dev/null && echo "  livez: 200"
echo "Check $BASE/readyz ..."
set +e
code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/readyz")
set -e
echo "  readyz: $code"
[ "$code" = "200" ] || exit 1
