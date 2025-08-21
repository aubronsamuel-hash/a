#!/usr/bin/env bash
set -euo pipefail
pkill -f "gunicorn .*backend.app.main:app" || true
