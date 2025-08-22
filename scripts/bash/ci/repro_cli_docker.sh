#!/usr/bin/env bash
set -euo pipefail
TAG="${1:-cli:test}"
echo "Build image $TAG"
docker build --pull -t "$TAG" -f Dockerfile.cli .
echo "Run image $TAG"
out="$(docker run --rm "$TAG")"
echo "$out"
grep -q "coulisses-cli: OK" <<<"$out"
echo "OK: CLI Docker"
