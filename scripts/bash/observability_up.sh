#!/usr/bin/env bash
set -euo pipefail
command -v docker >/dev/null 2>&1 || { echo "Docker non installe."; exit 1; }
docker compose -f docker-compose.observability.yml up -d --build
echo "Observabilite up: Prometheus http://localhost:9090, Grafana http://localhost:3000 (admin/admin)"
