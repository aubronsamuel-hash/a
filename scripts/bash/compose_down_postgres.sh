#!/usr/bin/env bash
set -euo pipefail
command -v docker >/dev/null 2>&1 || { echo "Docker non installe."; exit 1; }
docker compose -f docker-compose.postgres.yml down -v
echo "Stack Postgres arrete et volumes supprimes."
