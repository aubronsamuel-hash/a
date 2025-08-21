#!/usr/bin/env bash
set -euo pipefail
export PYTHONPATH=backend
exec gunicorn -c backend/gunicorn_conf.py backend.app.main:app
