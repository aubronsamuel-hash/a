$ErrorActionPreference = "Stop"
Param([string]$Msg = "change")
if (-not (Test-Path .venv\Scripts\python.exe)) { Write-Error "Venv manquante. PS1\setup.ps1" ; exit 1 }
Write-Host "Nouvelle revision: $Msg" -ForegroundColor Cyan
.venv\Scripts\python.exe -m alembic revision -m "$Msg"
Write-Host "OK revision creee." -ForegroundColor Green
