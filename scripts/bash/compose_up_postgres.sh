#!/usr/bin/env bash
set -euo pipefail
command -v docker >/dev/null 2>&1 || { echo "Docker non installe."; exit 1; }
docker compose -f docker-compose.postgres.yml up -d --build
echo "Postgres + backend demarres (http://localhost:8001)"
