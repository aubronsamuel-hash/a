Coulisses Crew - Monorepo
=========================

Monorepo FastAPI (backend) + React Vite (frontend). Windows-first (PowerShell), Linux/mac pris en charge (bash).

## Sommaire

- [Prérequis](#prerequis)
- [Démarrage rapide (Windows)](#demarrage-rapide-windows)
- [Démarrage rapide (Linux/mac)](#demarrage-rapide-linuxmac)
- [Configuration (.env)](#configuration-env)
- [Scripts utiles](#scripts-utiles)
- [Back-end (FastAPI)](#back-end-fastapi)
- [Front-end (Vite React)](#front-end-vite-react)
- [Docker Compose (Postgres)](#docker-compose-postgres)
- [PowerShell 7 (pwsh)](#powershell-7-pwsh)
- [Sans Docker](#sans-docker)
- [CI GitHub Actions](#ci-github-actions)
- [Tests et Qualité](#tests-et-qualite)
- [Observabilité](#observabilite)
- [Sécurité](#securite)
- [Dépannage](#depannage)
- [Roadmap / Étapes livrées](#roadmap--etapes-livrees)
- [Licence](#licence)

## Prérequis

- Windows 10/11 ou WSL2, ou Linux/macOS
- Python 3.11+
- Node.js 20+ et npm
- PowerShell (Windows: `powershell.exe`; cross-OS: `pwsh` 7.x optionnel)
- *(Optionnel)* Docker Desktop / `docker compose`
- *(Optionnel)* PostgreSQL 16 si hors Docker

## Démarrage rapide (Windows)

```powershell
# 1) Cloner et se placer à la racine
git clone <url> a
cd a

# 2) Copier la config par défaut
Copy-Item .env.example .env

# 3) Backend (venv + deps + migrations Alembic + run)
.\PS1\setup.ps1
.\PS1\alembic_upgrade.ps1
.\PS1\run_bg.ps1
# API: http://localhost:8001/healthz

# 4) Frontend
.\PS1\web_setup.ps1
.\PS1\web_run.ps1
# UI: http://localhost:5173

# 5) Tests rapides
.\PS1\test.ps1              # backend
.\PS1\web_test.ps1          # frontend
.\PS1\web_users_smoke.ps1   # ETag/304
.\PS1\smoke_rate_limit.ps1  # 401 -> 429
```

## Démarrage rapide (Linux/mac)

```bash
git clone <url> a && cd a
cp .env.example .env

# Backend
python -m pip install --upgrade pip
pip install -e backend[dev]
python -m alembic upgrade head
python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001 &
sleep 3
curl -sf http://localhost:8001/healthz

# Frontend
bash scripts/bash/web_setup.sh
VITE_API_BASE_URL=http://localhost:8001 npm --prefix web run dev &

# Tests
pytest -q --cov=backend
bash scripts/bash/web_test.sh
bash scripts/bash/web_users_smoke.sh   # nécessite admin seed
bash scripts/bash/smoke_rate_limit.sh
```

## Configuration (.env)

Fichier `.env` à la racine. Voir `.env.example` fourni. Points clés:

- `DB_DSN`: `sqlite:///./cc.db` (défaut) ou `postgresql+psycopg://user:pass@host:5432/db`
- `ADMIN_AUTOSEED=true`, `ADMIN_USERNAME`, `ADMIN_PASSWORD`
- JWT/REFRESH: secrets et TTL
- `CORS_ORIGINS`: p. ex. `http://localhost:5173`
- Observabilité: `REQUEST_ID_HEADER`, `LOG_JSON`
- Rate limiting: `RATE_LIMIT_*`

## Scripts utiles

### PowerShell (Windows-first)

- `PS1\setup.ps1` : venv + deps backend
- `PS1\run_bg.ps1` : lance l'API en arrière-plan (port 8001)
- `PS1\alembic_upgrade.ps1` | `alembic_downgrade.ps1` | `alembic_revision.ps1`
- `PS1\web_setup.ps1` : deps web
- `PS1\web_run.ps1` : lance Vite dev (port 5173)
- `PS1\web_test.ps1` : lint + tests front
- `PS1\web_users_smoke.ps1` : vérifie ETag/304 sur `/users`
- `PS1\smoke_rate_limit.ps1` : vérifie 401 puis 429 sur `/auth/token`
> Sur Windows sans PowerShell Core (`pwsh`), utilisez `powershell -File PS1\*.ps1`

### Bash (Linux/mac)

- `scripts/bash/alembic_upgrade.sh`
- `scripts/bash/web_setup.sh`, `web_run.sh`, `web_test.sh`
- `scripts/bash/web_users_smoke.sh` (nécessite admin seed)
- `scripts/bash/compose_up_redis.sh` (Docker Redis; message info si absent)
- `scripts/bash/smoke_rate_limit_redis.sh` (401 puis 429 via Redis)
- `scripts/bash/smoke_rate_limit.sh` (fallback mémoire)
- `scripts/bash/api_start_autoseed.sh` (helper: API + autoseed rapide)

#### Redis (optionnel)

Sans Docker:

```bash
bash scripts/bash/smoke_rate_limit.sh
```

Avec Docker:

```bash
bash scripts/bash/compose_up_redis.sh
bash scripts/bash/smoke_rate_limit_redis.sh
```

### Docker (image unique)

Build et run locaux:

```
# Windows
.\PS1\docker_build.ps1
.\PS1\docker_run.ps1
.\PS1\docker_smoke.ps1

# Linux/mac
bash scripts/bash/docker_build.sh
bash scripts/bash/docker_run.sh
bash scripts/bash/docker_smoke.sh
```

L'image sert l'API (`/healthz`) et le SPA sur `/` (FRONT_DIST_DIR=/app/public).

## Back-end (FastAPI)

Base URL: `http://localhost:8001`

Endpoints principaux:

- `GET /healthz` (version)
- `GET /livez`, `GET /readyz`
- `GET /metrics` (Prometheus)
- `POST /auth/token` (access+refresh)
- `POST /auth/refresh`
- `POST /auth/change-password` (auth)
- `GET /auth/me` (auth)
- `GET /users` (admin-only) : pagination meta + tri + ETag/304
- `POST /users` (admin-only)
- `POST /users/{username}/promote` (admin-only)

RBAC: rôle user/admin dans le token.

Rate limiting: global et spécifique `/auth/token` (429 + `Retry-After`).

## Front-end (Vite React)

Dev: `http://localhost:5173`

Config: `VITE_API_BASE_URL`

Pages:

- Login -> `me()`
- Dashboard simple: bouton secret, rôle affiché
- Admin Users: table, pagination/tri, cache ETag (If-None-Match), badge *from cache*

Tests: Vitest (helpers d'API et cache).

## Docker Compose (Postgres)

### Windows

```powershell
Copy-Item .env.example .env
# Optionnel: setx DB_DSN "postgresql+psycopg://app:app@localhost:5432/app"
.\PS1\compose_up.ps1
# API: http://localhost:8001/healthz
```

### Linux/mac

```bash
cp .env.example .env
docker compose up -d --build
curl -sf http://localhost:8001/healthz
```

## PowerShell 7 (pwsh)

### Linux (Debian/Ubuntu)

```
sudo bash scripts/bash/install_pwsh.sh
pwsh -NoProfile -Command "$PSVersionTable.PSVersion"
```

### Windows

```
# en PowerShell admin
./PS1/install_pwsh_on_windows.ps1
# ou directement:
winget install --id Microsoft.PowerShell -e
# ou:
choco install powershell-core -y
```

Si pwsh indisponible, utilisez les scripts Bash (`scripts/bash/*.sh`) qui couvrent toutes les taches courantes.

## Sans Docker

Docker n est pas requis pour le dev local:

```
bash scripts/bash/web_build.sh
FRONT_DIST_DIR=$(pwd)/web/dist python -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001
# Smoke:
curl -sf http://localhost:8001/healthz && curl -sf http://localhost:8001/ | head -c 60
```

## CI GitHub Actions

Jobs :

- `backend` (lint ruff, mypy, pytest SQLite)
- `windows_smoke` (`setup.ps1`, `run_bg.ps1`, `smoke_auth.ps1`)
- `compose_smoke` (docker compose + healthz)
- `postgres_tests` (service Postgres, alembic upgrade, tests)
- `frontend` (npm ci, lint, test, build, smoke ETag cross-OS)

## Tests et Qualité

- Lint Python : `python -m ruff check backend`
- Typage : `python -m mypy backend`
- Tests Python : `PYTHONPATH=backend pytest -q --cov=backend`
- Lint/Test Web : `npm run lint`, `npm test` dans `web/`
- Smoke : voir [Scripts utiles](#scripts-utiles)

## Observabilité

- Header `X-Request-ID` (propagation auto)
- Logs JSON (activables via `LOG_JSON=true`)
- Prometheus : `GET /metrics`

## Sécurité

- JWT access/refresh, RBAC (admin/user)
- Rate limiting (429)
- Headers sécurité : `HSTS`, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `CSP`, `Permissions-Policy`
- CORS configurable

## Dépannage

- **401 sur /auth/token** : vérifier autoseed (`ADMIN_AUTOSEED=true`) ou créer un user admin.
- **304 non renvoyé** : changer tri/page ou vider cache front (`localStorage users:*`).
- **pwsh introuvable** : sur Windows utiliser `powershell.exe`; en CI fallback bash implémenté.
- **Docker indisponible sur runner** : le job `compose_smoke` se termine proprement en no-op.

## Roadmap / Étapes livrées

1. Setup backend de base
2. CI de base + fix ruff
3. Scripts Windows, smoke API
4. Front Vite + login/me/secret + CI front
5. Alembic + Postgres + CI postgres
6. RBAC admin/user + refresh + change password
7. Observabilité (X-Request-ID, logs JSON, /metrics, /livez, /readyz)
8. `/users` pagination meta + tri + ETag/304
9. Front Admin Users (cache ETag)
10. Rate limiting + security headers
11. Documentation (README)

## Licence

MIT (ou à définir).

