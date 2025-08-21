$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"
for ($i=1; $i -le 30; $i++) {
    try { $code = (Invoke-WebRequest -Uri "$Base/healthz" -TimeoutSec 2 -ErrorAction Stop).StatusCode } catch { $code = 0 }
    if ($code -eq 200) { break } ; Start-Sleep -Seconds 1
}
if ($code -ne 200) { Write-Error "API indisponible ($code)" ; exit 1 }
$home = Invoke-WebRequest -Uri "$Base/" -TimeoutSec 3
if ($home.StatusCode -ne 200) { Write-Error "/ renvoie $($home.StatusCode)" ; exit 1 }
Write-Host "Docker smoke OK (healthz 200, / 200)" -ForegroundColor Green
