$ErrorActionPreference = "Stop"
if (-not (Test-Path .\web\package.json)) { Write-Error "Dossier web introuvable" ; exit 1 }
Push-Location web
npm ci

# 3 tentatives d install du navigateur
$ok = $false
for ($i=1; $i -le 3; $i++) {
    try {
        npx playwright install chromium --with-deps
        $ok = $true
        break
    } catch {
        Write-Warning "Retry playwright install ($i/3)..."
        Start-Sleep -Seconds 3
    }
}
if (-not $ok) { Write-Error "Echec installation Chromium apres 3 tentatives." ; exit 1 }
Pop-Location
Write-Host "Playwright installe." -ForegroundColor Green
