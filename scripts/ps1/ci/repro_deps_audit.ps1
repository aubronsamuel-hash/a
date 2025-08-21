pip install pip-audit==2.7.3
if (Test-Path "requirements.txt") { pip-audit -r requirements.txt -l --progress-spinner=off --policy pip-audit.toml }
if (Test-Path "requirements-dev.txt") { pip-audit -r requirements-dev.txt -l --progress-spinner=off --policy pip-audit.toml }
