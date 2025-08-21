#!/usr/bin/env bash
set -euo pipefail
ENV_FILE="${1:-monitoring/.env}"
if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE"; set +a
fi
docker compose -f monitoring/docker-compose.monitoring.yml up -d
echo "Stack monitoring demarree."
