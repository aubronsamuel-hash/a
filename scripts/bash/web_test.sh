#!/usr/bin/env bash
set -euo pipefail
cd web
npm run lint
npm test
echo "Web tests OK"
