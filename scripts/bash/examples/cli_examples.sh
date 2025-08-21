#!/usr/bin/env bash
set -euo pipefail

# Lister
bash scripts/bash/ccadmin.sh list

# Creer
bash scripts/bash/ccadmin.sh create --username alice --password pw

# Promouvoir
bash scripts/bash/ccadmin.sh promote --username alice

# Reset password
bash scripts/bash/ccadmin.sh reset-password --username alice --new-password newpw
