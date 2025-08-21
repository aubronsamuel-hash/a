Backend (FastAPI)
=================

### Installation dev (editable)

Depuis la racine du repo:

```
python -m pip install --upgrade pip
python -m pip install -e backend[dev]
```

Si vous voyez `Multiple top-level packages discovered`, assurez-vous d utiliser ce `pyproject.toml` et que le package s appelle bien `app`.

## Setup (Windows)

```powershell
Copy-Item ..\.env.example ..\.env
.\PS1\setup.ps1
.\PS1\alembic_upgrade.ps1
.\PS1\run_bg.ps1
```

### Scripts PowerShell de repro rapide

```
# Installation (editable + dev)
python -m pip install --upgrade pip
python -m pip install -e backend[dev]

# Lints/typing/tests
python -m ruff check backend
python -m mypy backend
PYTHONPATH=backend pytest -q -k "version_consistency or bump_version_dry"
```

## Setup (Linux/mac)

```bash
cp ../.env.example ../.env
python -m pip install --upgrade pip
pip install -e backend[dev]
python -m alembic upgrade head
python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001
```

### Tests (Bash) rapides

```
python -m pip install --upgrade pip
python -m pip install -e backend[dev]
python -m ruff check backend
python -m mypy backend
PYTHONPATH=backend pytest -q -k "version_consistency or bump_version_dry"
```

## Tests

```powershell
python -m ruff check backend
python -m mypy backend
pytest -q --cov=backend
```

## Endpoints

- `GET /healthz`, `GET /livez`, `GET /readyz`, `GET /metrics`
- Auth: `/auth/token`, `/auth/refresh`, `/auth/change-password`, `/auth/me`
- Users (admin) : `GET /users`, `POST /users`, `POST /users/{username}/promote`

## DB/Migrations

- SQLite par défaut
- Postgres via `DB_DSN`
- Alembic : `PS1\alembic_upgrade.ps1`, `PS1\alembic_revision.ps1 -Msg "..."`

