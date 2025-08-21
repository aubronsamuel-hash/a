#!/usr/bin/env bash
set -euo pipefail
PORT="${DOCS_PORT:-8001}"
command -v mkdocs >/dev/null || { echo "mkdocs introuvable"; exit 2; }
mkdocs serve -a 0.0.0.0:"$PORT"
