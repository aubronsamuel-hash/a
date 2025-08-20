#!/usr/bin/env bash
set -euo pipefail
. .venv/bin/activate
python -m ruff check backend
python -m mypy backend
pytest -q --cov=backend

