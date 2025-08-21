$ErrorActionPreference = "Stop"
if (-not (Test-Path .\web\package.json)) { Write-Error "Dossier web introuvable" ; exit 1 }
Push-Location web
npm ci
npx playwright install --with-deps
Pop-Location
Write-Host "Playwright installe." -ForegroundColor Green
