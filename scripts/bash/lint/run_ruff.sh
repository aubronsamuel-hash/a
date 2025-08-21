#!/usr/bin/env bash
set -euo pipefail
ruff check "${1:-.}"
