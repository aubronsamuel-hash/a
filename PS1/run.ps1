$ErrorActionPreference = "Stop"
if (-not (Test-Path .\.venv\Scripts\python.exe)) {
    Write-Error "Environnement non initialise. Lancez PS1\setup.ps1" ; exit 1
}
$env:APP_ENV = "dev"
$env:APP_LOG_LEVEL = "info"
Write-Host "Lancement API sur http://localhost:8001 ..." -ForegroundColor Cyan
.\.venv\Scripts\python.exe -m uvicorn app.main:app --app-dir backend --host 0.0.0.0 --port 8001
