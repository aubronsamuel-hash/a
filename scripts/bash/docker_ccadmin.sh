#!/usr/bin/env bash
set -euo pipefail
IMAGE="${IMAGE:-ccapi:local}"
VOLUME="${VOLUME:-ccapi_cli_data}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker non installe. Installez Docker ou utilisez 'bash scripts/bash/ccadmin.sh' (Python local requis)." >&2
  exit 1
fi

CMD="${1:-}"; shift || true
[ -n "$CMD" ] || { echo "Usage: $0 <list|create|promote|reset-password> [args]"; exit 1; }

# Build si image absente

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Image $IMAGE absente. Construction..."
  docker build -t "$IMAGE" .
fi

docker volume create "$VOLUME" >/dev/null

BASE_RUN=(docker run --rm -e DB_DSN="sqlite:////data/cc.db" -v "${VOLUME}:/data" "$IMAGE" ccadmin)

case "$CMD" in
  list)
    "${BASE_RUN[@]}" list
    ;;
  create)
    # --username --password [--role]
    "${BASE_RUN[@]}" create "$@"
    ;;
  promote)
    # --username
    "${BASE_RUN[@]}" promote "$@"
    ;;
  reset-password)
    # --username --new-password
    "${BASE_RUN[@]}" reset-password "$@"
    ;;
  *)
    echo "Commande inconnue: $CMD" >&2
    exit 2
    ;;
esac
