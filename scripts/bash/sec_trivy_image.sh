#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:-ccapi:cli-ci}"
OUT="${2:-reports/trivy.sarif}"
mkdir -p "$(dirname "$OUT")"
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker non installe; skip du scan d image." >&2
    exit 0
fi
if ! command -v trivy >/dev/null 2>&1; then
    docker pull aquasec/trivy:latest >/dev/null
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/work" -w /work aquasec/trivy:latest image --severity HIGH,CRITICAL --scanners vuln --format sarif -o "$OUT" "$IMAGE"
    exit $?
fi
trivy image --severity HIGH,CRITICAL --scanners vuln --format sarif -o "$OUT" "$IMAGE"
