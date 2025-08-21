#!/usr/bin/env bash
set -euo pipefail
docker build -t cli:test -f Dockerfile.cli .
docker run --rm cli:test
