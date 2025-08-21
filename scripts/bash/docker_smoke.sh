#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://localhost:8001}
for i in {1..30}; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/healthz" || true)
    [ "$code" = "200" ] && break
    sleep 1
done
if [ "${code:-0}" != "200" ]; then
    echo "API indisponible ($code)" >&2
    exit 1
fi
code_root=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/")
[ "$code_root" = "200" ] || { echo "/ renvoie $code_root" >&2; exit 1; }
echo "Docker smoke OK (healthz 200, / 200)"
