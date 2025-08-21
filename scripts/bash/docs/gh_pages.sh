#!/usr/bin/env bash
set -euo pipefail
command -v mkdocs >/dev/null || { echo "mkdocs introuvable"; exit 2; }
mkdocs gh-deploy --force
