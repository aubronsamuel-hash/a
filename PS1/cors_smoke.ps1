param(
    [string]$Base = "http://localhost:8001",
    [string]$Origin = "http://localhost:5173"
)
$ErrorActionPreference = "Stop"
$Headers = @{
"Origin" = $Origin
"Access-Control-Request-Method" = "POST"
"Access-Control-Request-Headers" = "Authorization,Content-Type"
}
$r = Invoke-WebRequest -UseBasicParsing -Method Options -Uri "$Base/healthz" -Headers $Headers -TimeoutSec 5
Write-Host "Status: $($r.StatusCode)"
$r.Headers.GetEnumerator() | ? { $_.Name -like "Access-Control-*" } | % { Write-Host "$($_.Name): $($_.Value)" -ForegroundColor Cyan }
