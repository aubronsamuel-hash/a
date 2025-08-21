#!/usr/bin/env bash
set -euo pipefail
command -v docker >/dev/null 2>&1 || { echo "Docker non installe."; exit 1; }
docker compose -f docker-compose.observability.yml down -v
echo "Observabilite down (volumes supprimes)"
