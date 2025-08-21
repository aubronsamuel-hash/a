#!/usr/bin/env bash
set -euo pipefail
ENV_NAME="${1:-dev}"
cp ".env.${ENV_NAME}" .env
export ENV="$ENV_NAME"
echo "ENV bascule -> ${ENV_NAME} (copie .env.${ENV_NAME} -> .env)"
