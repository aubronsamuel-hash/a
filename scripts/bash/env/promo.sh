#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:-example/app}"
FROM_TAG="${2:-staging}"
TO_TAG="${3:-prod}"
PUSH="${4:-false}"
echo "Promote ${IMAGE}:${FROM_TAG} -> ${IMAGE}:${TO_TAG}"
docker tag "${IMAGE}:${FROM_TAG}" "${IMAGE}:${TO_TAG}"
if [ "${PUSH}" = "true" ]; then docker push "${IMAGE}:${TO_TAG}"; fi
