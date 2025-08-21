#!/usr/bin/env bash
set -euo pipefail
mypy "${1:-backend}"
