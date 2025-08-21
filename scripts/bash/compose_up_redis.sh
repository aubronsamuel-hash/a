#!/usr/bin/env bash
set -euo pipefail
if [ ! -f docker-compose.yml ]; then
  echo "Warning: docker-compose.yml introuvable (on suppose un fichier base existant ailleurs)." >&2
fi
docker compose -f docker-compose.yml -f docker-compose.redis.yml up -d --build
echo "Stack Redis up. BACKEND utilise RATE_LIMIT_BACKEND=redis."

