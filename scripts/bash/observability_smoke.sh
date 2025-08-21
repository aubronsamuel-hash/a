#!/usr/bin/env bash
set -euo pipefail
PROM="${1:-http://localhost:9090}"
curl -fsS "$PROM/-/ready" >/dev/null
curl -fsS "$PROM/api/v1/targets" | grep -q '"job":"ccapi"'
echo "Prometheus OK, job ccapi cible"
