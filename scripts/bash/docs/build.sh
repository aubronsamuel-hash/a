#!/usr/bin/env bash
set -euo pipefail
command -v mkdocs >/dev/null || { echo "mkdocs introuvable"; exit 2; }
mkdocs build --clean && echo "OK: build docs"
