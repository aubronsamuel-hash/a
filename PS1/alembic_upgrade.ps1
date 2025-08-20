$ErrorActionPreference = "Stop"
if (-not (Test-Path .venv\Scripts\python.exe)) { Write-Error "Venv manquante. PS1\setup.ps1" ; exit 1 }
Write-Host "Migration DB -> head..." -ForegroundColor Cyan
.venv\Scripts\python.exe -m alembic upgrade head
Write-Host "OK migrations appliquees." -ForegroundColor Green
