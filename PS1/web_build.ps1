$ErrorActionPreference = "Stop"
if (-not (Test-Path .\web\package.json)) { Write-Error "Dossier web introuvable" ; exit 1 }
Push-Location web
if (-not (Test-Path .\node_modules)) { npm ci }
npm run build
Pop-Location
if (-not (Test-Path .\web\dist\index.html)) { Write-Error "Build Vite introuvable (web/dist/index.html absent)" ; exit 1 }
Write-Host "Build front OK. Pour servir via backend:" -ForegroundColor Green
Write-Host " powershell -Command `$env:FRONT_DIST_DIR='$(Join-Path (Get-Location) 'web\dist')'; python -m uvicorn app.main:app --app-dir backend --port 8001" -ForegroundColor DarkCyan
