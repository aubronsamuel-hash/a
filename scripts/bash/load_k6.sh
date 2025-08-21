#!/usr/bin/env bash
set -euo pipefail
VUS="${1:-10}"
DUR="${2:-20}"
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker non installe; test k6 skippe." >&2
  exit 0
fi
docker build -t ccapi:k6 .
docker compose -f docker-compose.k6.yml up -d --build

# wait health

for i in $(seq 1 90); do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/healthz || true)
  [ "$code" = "200" ] && break
  sleep 2
done
mkdir -p load/k6
docker run --rm --network cc-k6_default -v "$PWD/load/k6:/scripts" -e BASE="http://backend:8001" grafana/k6:latest run --vus "$VUS" --duration "${DUR}s" --summary-export /scripts/summary.json /scripts/smoke.js
rc=$?
docker compose -f docker-compose.k6.yml down -v
exit $rc
