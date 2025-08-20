$ErrorActionPreference = "Stop"
Param([string]$Rev = "-1")
if (-not (Test-Path .venv\Scripts\python.exe)) { Write-Error "Venv manquante. PS1\setup.ps1" ; exit 1 }
Write-Host "Downgrade DB -> $Rev ..." -ForegroundColor Yellow
.venv\Scripts\python.exe -m alembic downgrade $Rev
Write-Host "OK downgrade." -ForegroundColor Green
