#!/usr/bin/env bash
set -euo pipefail
docker compose -f monitoring/docker-compose.monitoring.yml down -v
echo "Stack monitoring arretee et volumes supprimes."
