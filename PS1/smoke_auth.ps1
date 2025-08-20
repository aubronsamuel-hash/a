$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"
$User = $env:ADMIN_USERNAME; if (-not $User) { $User = "admin" }
$Pass = $env:ADMIN_PASSWORD; if (-not $Pass) { $Pass = "admin123" }

Write-Host "== HEALTH ==" -ForegroundColor Cyan
$h = Invoke-RestMethod -Method GET -Uri "$Base/healthz" -TimeoutSec 10
"Health: $($h.status) v$($h.version)"

Write-Host "== LOGIN ==" -ForegroundColor Cyan
$t = Invoke-RestMethod -Method POST -Uri "$Base/auth/token" -ContentType "application/json" -Body (@{username=$User; password=$Pass} | ConvertTo-Json)
$TOKEN = $t.access_token
if (-not $TOKEN) { throw "Pas de token recu" }
Write-Host "Token OK (len=$($TOKEN.Length))" -ForegroundColor Green

Write-Host "== /auth/me ==" -ForegroundColor Cyan
$r = Invoke-RestMethod -Method GET -Uri "$Base/auth/me" -Headers @{Authorization="Bearer $TOKEN"} -TimeoutSec 10
"User: $($r.username)"
Write-Host "Smoke auth OK" -ForegroundColor Green
