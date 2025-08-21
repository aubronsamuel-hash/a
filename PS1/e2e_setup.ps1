$ErrorActionPreference = "Stop"
if (-not (Test-Path .\web\package.json)) { Write-Error "Dossier web introuvable" ; exit 1 }
Push-Location web
npm ci
Pop-Location

# Chrome systeme ?
$chrome = & .\PS1\find_chrome.ps1 2>$null
if ($LASTEXITCODE -eq 0 -and $chrome) {
  Write-Host "Navigateur systeme detecte: $chrome" -ForegroundColor Cyan
  $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"
  return
}

# Install Chromium (3 tentatives)
Push-Location web
$ok = $false
for ($i=1; $i -le 3; $i++) {
  try { npx playwright install chromium --with-deps ; $ok = $true ; break } catch {
    Write-Warning "Retry playwright install chromium ($i/3)..."; Start-Sleep -Seconds 3
  }
}
Pop-Location
if (-not $ok) {
  if ($env:CI -eq "true") { Write-Error "Echec install Chromium (CI)" ; exit 1 }
  else { Write-Warning "Echec install Chromium (local) -> E2E SKIP" ; return }
}
