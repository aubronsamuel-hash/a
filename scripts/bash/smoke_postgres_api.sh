#!/usr/bin/env bash
set -euo pipefail
BASE="${BASE:-http://localhost:8001}"
for i in $(seq 1 60); do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)
    [ "$code" = "200" ] && break
    sleep 1
done
[ "${code:-0}" = "200" ] || { echo "API indisponible ($code)"; exit 1; }
code_root=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/" || true)
[ "$code_root" = "200" ] || echo "Note: / renvoie $code_root (SPA non build?)"
echo "Smoke API OK (healthz 200)"
