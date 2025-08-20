#!/usr/bin/env bash
set -euo pipefail
: "${DB_DSN:=sqlite:///./cc.db}"
python -m alembic upgrade head
echo "Migrations OK"
