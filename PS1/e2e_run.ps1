$ErrorActionPreference = "Stop"
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
$env:APP_ENV="ci"; $env:ADMIN_AUTOSEED="true"; $env:ADMIN_USERNAME="admin"
if (-not $env:ADMIN_PASSWORD) { $env:ADMIN_PASSWORD="admin123" }

function Get-Health { try { (Invoke-WebRequest -Uri "http://localhost:8001/healthz" -TimeoutSec 3 -ErrorAction Stop).StatusCode } catch { 0 } }
if ((Get-Health) -ne 200) {
  .\PS1\setup.ps1
  Start-Process -WindowStyle Hidden -FilePath python -ArgumentList "-m","uvicorn","app.main:app","--app-dir","backend","--host","0.0.0.0","--port","8001"
  Start-Sleep -Seconds 5
}

$chrome = & .\PS1\find_chrome.ps1 2>$null
if ($LASTEXITCODE -eq 0 -and $chrome) {
  $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"
  $env:CHROMIUM_EXECUTABLE = $chrome
} else {
  Push-Location web
  try {
    $list = npx playwright browsers ls
    if ($list -notmatch "chromium") { npx playwright install chromium }
  } catch {
    if ($env:CI -eq "true") { Write-Error "Playwright Chromium indisponible en CI" ; exit 1 }
    else { Write-Warning "E2E SKIP local (navigateurs indisponibles)" ; $env:E2E_SKIP="1" }
  }
  Pop-Location
}

Push-Location web
npm run build
npx playwright test
Pop-Location
