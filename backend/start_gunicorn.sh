#!/usr/bin/env bash
set -euo pipefail
exec gunicorn \
  -c backend/gunicorn_conf.py \
  "backend.app.main:app"
