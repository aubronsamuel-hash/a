# Multi-env (dev/staging/prod)

Bascule locale (Windows):

* .\scripts\ps1\env\use-env.ps1 -Env dev
* .\scripts\ps1\env\use-env.ps1 -Env staging
* .\scripts\ps1\env\use-env.ps1 -Env prod

Compose (exemples):

* docker compose -f docker/compose.yml -f docker/env/dev.yml up -d
* docker compose -f docker/compose.yml -f docker/env/staging.yml up -d
* docker compose -f docker/compose.yml -f docker/env/prod.yml up -d

Promotion image (dry-run par defaut):

* .\scripts\ps1\env\promo.ps1 -Image example/app -FromTag staging -ToTag prod -DryRun
* .\scripts\ps1\env\promo.ps1 -Image example/app -FromTag staging -ToTag prod -Push

Tests (PowerShell + pytest):

* PYTHONPATH=backend pytest -q backend/tests/test_settings_env.py  # 2 passed
* Bascule: .\scripts\ps1\env\use-env.ps1 -Env staging
