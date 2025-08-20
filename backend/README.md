# ETAPE 5 - Alembic + PostgreSQL

* SQLite par defaut pour le dev rapide
* Postgres via DB_DSN et docker-compose (service db)
* Alembic: upgrade/downgrade/revision

## PowerShell (Windows)

PS> .\PS1\setup.ps1
PS> .\PS1\alembic_upgrade.ps1
PS> .\PS1\run_bg.ps1

## Docker Compose (Postgres)

PS> Copy-Item .env.example .env

# Optionnel: setx DB_DSN "postgresql+psycopg://app:app@localhost:5432/app"

PS> .\PS1\compose_up.ps1
