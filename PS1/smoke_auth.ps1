$ErrorActionPreference = "Stop"
try {
    $resp = Invoke-WebRequest -UseBasicParsing http://localhost:8001/healthz -TimeoutSec 5
    if ($resp.StatusCode -ne 200) { throw "HTTP $($resp.StatusCode)" }
    Write-Host "OK /healthz 200" -ForegroundColor Green
} catch {
    Write-Error "Smoke test failed: $_"
    exit 1
}
