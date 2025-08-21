$ErrorActionPreference = "Stop"
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
$env:APP_ENV="ci"
$env:ADMIN_AUTOSEED="true"
$env:ADMIN_USERNAME="admin"
if (-not $env:ADMIN_PASSWORD) { $env:ADMIN_PASSWORD="admin123" }

# Demarrer backend si healthz != 200
function Get-Health { try { (Invoke-WebRequest -Uri "http://localhost:8001/healthz" -TimeoutSec 3 -ErrorAction Stop).StatusCode } catch { 0 } }
if ((Get-Health) -ne 200) {
    .\PS1\setup.ps1
    Start-Process -WindowStyle Hidden -FilePath python -ArgumentList "-m","uvicorn","app.main:app","--app-dir","backend","--host","0.0.0.0","--port","8001"
    Start-Sleep -Seconds 5
}

# Auto-install des browsers si manquants
Push-Location web
try {
    $list = npx playwright browsers ls
    if ($list -notmatch "chromium") {
        npx playwright install chromium
    }
} catch {
    npx playwright install chromium
}
npm run build
npx playwright test
Pop-Location
