$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"

function Try-Login($u,$p) {
    try {
        Invoke-RestMethod -Uri "$Base/auth/token" -Method POST -ContentType application/json -Body (@{username=$u;password=$p} | ConvertTo-Json) -TimeoutSec 5 | Out-Null
        return 200
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) { return [int]$_.Exception.Response.StatusCode.value__ }
        else { return 0 }
    }
}

Write-Host "Test rate limit /auth/token ..." -ForegroundColor Cyan
$statuses = @()
for ($i=1; $i -le 20; $i++) {
    $code = Try-Login "admin" "badpassword"
    $statuses += $code
    Start-Sleep -Milliseconds 100
}
$has401 = $statuses | Where-Object { $_ -eq 401 }
$has429 = $statuses | Where-Object { $_ -eq 429 }
if (-not $has401) { Write-Error "Attendu au moins 1 reponse 401" ; exit 1 }
if (-not $has429) { Write-Error "Attendu au moins 1 reponse 429 (limite atteinte)" ; exit 1 }
Write-Host "Rate limit OK (401 puis 429)" -ForegroundColor Green
