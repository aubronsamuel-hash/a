#!/usr/bin/env bash
set -euo pipefail
msg="${1:?Usage: $0 \"message\"}"
alembic revision --autogenerate -m "$msg"
