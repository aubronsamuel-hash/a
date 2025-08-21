#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "[INFO] Docker n'est pas installe dans cet environnement." >&2
  echo "[TIP ] Utilisez le fallback memory: bash scripts/bash/smoke_rate_limit.sh" >&2
  exit 0
fi

if [ ! -f docker-compose.yml ]; then
  echo "[WARN] docker-compose.yml introuvable. On suppose qu'il existe dans votre stack principale." >&2
fi

echo "[INFO] Lancement du stack Redis via compose..."
docker compose -f docker-compose.yml -f docker-compose.redis.yml up -d --build

echo "[INFO] Attente de readiness du backend sur http://localhost:8001/healthz ..."
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/healthz || true)
  [ "$code" = "200" ] && echo "[OK] Backend up." && exit 0
  sleep 1
done

echo "[ERROR] Backend indisponible apres attente. Verifiez les logs 'docker compose logs backend'." >&2
exit 1
