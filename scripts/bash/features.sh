#!/usr/bin/env bash
set -euo pipefail
BASE="${1:-http://localhost:8001}"
body="$(curl -fsS "$BASE/features")"
echo "$body"
xf="$(curl -fsSI "$BASE/features" | awk 'BEGIN{IGNORECASE=1}/^X-Features\:/{print substr($0,index($0,$2))}')"
echo "X-Features: ${xf}"
