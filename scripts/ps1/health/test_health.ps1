$base = "http://localhost:8000"
Write-Host "== Test /healthz ==" -ForegroundColor Cyan
$r = Invoke-RestMethod -Uri "$base/healthz" -Method GET
if ($r.status -ne "ok") { Write-Host "FAIL healthz" -ForegroundColor Red; exit 1 }
Write-Host "OK healthz" -ForegroundColor Green

Write-Host "== Test /readyz ==" -ForegroundColor Cyan
try {
    $r2 = Invoke-RestMethod -Uri "$base/readyz" -Method GET
    Write-Host "Status: $($r2.status)" -ForegroundColor Green
} catch {
    Write-Host "FAIL readyz" -ForegroundColor Red; exit 1 }
