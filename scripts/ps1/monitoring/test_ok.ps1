param(
    [string]$Prom="http://localhost:9090",
    [string]$Graf="http://localhost:3000"
)
Write-Host "Test OK: endpoints Prometheus et Grafana accesibles" -ForegroundColor Cyan
try {
    $p = Invoke-WebRequest -UseBasicParsing "$Prom/-/ready" -TimeoutSec 5
    if ($p.StatusCode -ne 200) { throw "Prometheus non pret (HTTP $($p.StatusCode))" }
    $g = Invoke-WebRequest -UseBasicParsing "$Graf/login" -TimeoutSec 5
    if ($g.StatusCode -ne 200) { throw "Grafana non accessible (HTTP $($g.StatusCode))" }
    Write-Host "OK" -ForegroundColor Green
} catch {
    Write-Host "Echec: $($_.Exception.Message)" -ForegroundColor Red; exit 1
}
