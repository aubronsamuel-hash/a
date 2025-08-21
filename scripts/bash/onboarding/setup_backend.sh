#!/usr/bin/env bash
set -euo pipefail
python -m venv .venv || true
source .venv/bin/activate
pip install -U pip
[ -f requirements.txt ] && pip install -r requirements.txt || true
[ -f requirements-dev.txt ] && pip install -r requirements-dev.txt || true
echo "OK: deps installees"
