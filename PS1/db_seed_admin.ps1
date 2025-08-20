$ErrorActionPreference = "Stop"
if (-not (Test-Path .\.venv\Scripts\python.exe)) {
  Write-Error "Environnement non initialise. PS1\setup.ps1" ; exit 1
}
$env:ADMIN_AUTOSEED = "true"
if (-not $env:ADMIN_USERNAME) { $env:ADMIN_USERNAME = "admin" }
if (-not $env:ADMIN_PASSWORD) { $env:ADMIN_PASSWORD = "admin123" }
Write-Host "Seed admin via redemarrage API (create_all + autoseed)..." -ForegroundColor Cyan
Write-Host "OK. Redemarrez l API pour appliquer." -ForegroundColor Green
