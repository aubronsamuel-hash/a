#!/usr/bin/env bash
set -euo pipefail
IMAGE="${IMAGE:-ccapi:local}"
if ! command -v docker >/dev/null 2>&1; then echo "Docker non installe."; exit 1; fi
docker image inspect "$IMAGE" >/dev/null 2>&1 || docker build -t "$IMAGE" .

# create OK

docker run --rm -e DB_DSN="postgresql+psycopg://cc:cc@localhost:5432/ccdb" "$IMAGE" ccadmin create --username alice --password pw

# duplicate KO (exit 1)

set +e
docker run --rm -e DB_DSN="postgresql+psycopg://cc:cc@localhost:5432/ccdb" "$IMAGE" ccadmin create --username alice --password pw
rc=$?
set -e
[ "$rc" -eq 1 ] || { echo "Duplicat doit retourner exit 1 (rc=$rc)"; exit 1; }
echo "Smoke CLI OK (create OK, duplicat = 1)"
