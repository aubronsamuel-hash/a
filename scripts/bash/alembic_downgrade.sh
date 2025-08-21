#!/usr/bin/env bash
set -euo pipefail
alembic downgrade "${1:--1}"
