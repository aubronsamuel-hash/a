$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"
for ($i=1; $i -le 60; $i++) {
    try { $code = (Invoke-WebRequest -Uri "$Base/healthz" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop).StatusCode } catch { $code = 0 }
    if ($code -eq 200) { break } ; Start-Sleep -Seconds 1
}
if ($code -ne 200) { Write-Error "API indisponible ($code)"; exit 1 }
$codeRoot = (Invoke-WebRequest -Uri "$Base/" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue).StatusCode
if ($codeRoot -ne 200) { Write-Warning "/ renvoie $codeRoot (SPA peut etre non build)"; }
Write-Host "Smoke API OK (healthz 200)" -ForegroundColor Green
