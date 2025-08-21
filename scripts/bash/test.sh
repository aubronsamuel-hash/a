#!/usr/bin/env bash
set -euo pipefail
. .venv/bin/activate
python -m ruff check backend
python -m mypy backend
pytest -q --cov=backend

# Smoke audit rapide (non bloquant)
set +e
code=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H 'Content-Type: application/json' -d '{"username":"admin","password":"bad"}' http://localhost:8001/auth/token)
echo "Smoke audit (bad login) HTTP=$code"
set -e

