#!/usr/bin/env bash
set -euo pipefail
. .venv/bin/activate
ruff check backend
mypy backend
pytest -q --cov=backend
