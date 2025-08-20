#!/usr/bin/env bash
set -euo pipefail
. .venv/bin/activate
ruff backend
mypy backend
pytest -q --cov=backend
