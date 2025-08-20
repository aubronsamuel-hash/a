#!/usr/bin/env bash
set -euo pipefail
cd web
npm ci
echo "Web deps OK"
