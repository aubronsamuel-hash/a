#!/usr/bin/env bash
set -euo pipefail
docker compose -f monitoring/docker-compose.monitoring.yml logs -f --tail=200
