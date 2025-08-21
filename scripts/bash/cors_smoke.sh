#!/usr/bin/env bash
set -euo pipefail
BASE="${1:-http://localhost:8001}"
ORIGIN="${2:-http://localhost:5173}"
curl -i -X OPTIONS "$BASE/healthz" \
  -H "Origin: $ORIGIN" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Authorization,Content-Type" \
  | sed -n '1,30p' | awk 'BEGIN{IGNORECASE=1}/^Access-Control-/{print}'
