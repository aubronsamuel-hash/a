#!/usr/bin/env bash
set -euo pipefail
BASE="http://localhost:8000"
echo "== Test /healthz =="
STATUS=$(curl -s $BASE/healthz | jq -r .status)
if [ "$STATUS" != "ok" ]; then echo "FAIL healthz"; exit 1; fi
echo "OK healthz"

echo "== Test /readyz =="
curl -s -o /dev/null -w "%{http_code}" $BASE/readyz
