$ErrorActionPreference = "Stop"
if (-not (Test-Path .\web\package.json)) { Write-Error "Dossier web introuvable" ; exit 1 }
Push-Location web
npm ci
Pop-Location
Write-Host "Web deps installees." -ForegroundColor Green
