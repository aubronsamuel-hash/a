Backend (FastAPI)
=================

## Setup (Windows)

```powershell
Copy-Item ..\.env.example ..\.env
.\PS1\setup.ps1
.\PS1\alembic_upgrade.ps1
.\PS1\run_bg.ps1
```

## Setup (Linux/mac)

```bash
cp ../.env.example ../.env
python -m pip install --upgrade pip
pip install -e backend[dev]
python -m alembic upgrade head
python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001
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

