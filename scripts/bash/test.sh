#!/usr/bin/env bash
set -euo pipefail

# Activer venv si present, sinon ignorer
if [ -f ".venv/bin/activate" ]; then
    # shellcheck disable=SC1091
    . ".venv/bin/activate"
else
    echo "[INFO] Aucun venv .venv detecte; utilisation de l'environnement courant."
fi

# Lints + tests backend
export PYTHONPATH="backend${PYTHONPATH:+:$PYTHONPATH}"
python -m ruff check backend
python -m mypy backend
pytest -q --cov=backend | tee /tmp/pytest.log

# Smokes non bloquants (deja tolerants)
set +e
bash scripts/bash/smoke_rate_limit.sh
bash scripts/bash/smoke_rate_limit_redis.sh
set -e
echo "[OK] scripts/bash/test.sh termine"

