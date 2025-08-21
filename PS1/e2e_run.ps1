$ErrorActionPreference = "Stop"

if (-not (Test-Path .env)) { Copy-Item .env.example .env }
$env:APP_ENV = "ci"
$env:ADMIN_AUTOSEED = "true"
$env:ADMIN_USERNAME = "admin"
if (-not $env:ADMIN_PASSWORD) { $env:ADMIN_PASSWORD = "admin123" }

try {
  $code = (Invoke-WebRequest -Uri "http://localhost:8001/healthz" -TimeoutSec 3 -ErrorAction Stop).StatusCode
} catch { $code = 0 }
if ($code -ne 200) {
  .\PS1\setup.ps1
  Start-Process -WindowStyle Hidden -FilePath python -ArgumentList "-m","uvicorn","app.main:app","--app-dir","backend","--host","0.0.0.0","--port","8001"
  Start-Sleep -Seconds 5
}

Push-Location web
$env:CI = "1"
npm run build
npx playwright test
Pop-Location
