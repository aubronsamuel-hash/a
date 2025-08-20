$ErrorActionPreference = "Stop"
$Base = "http://localhost:8001"
$User = $env:DEV_USER; if (-not $User) { $User = "admin" }
$Pass = $env:DEV_PASSWORD; if (-not $Pass) { $Pass = "admin123" }

Write-Host "== HEALTH ==" -ForegroundColor Cyan
$h = Invoke-RestMethod -Method GET -Uri "$Base/healthz" -TimeoutSec 5
"Health: $($h.status) v$($h.version)"

Write-Host "== LOGIN ==" -ForegroundColor Cyan
try {
    $t = Invoke-RestMethod -Method POST -Uri "$Base/auth/token" `
        -ContentType "application/json" -Body (@{username=$User; password=$Pass} | ConvertTo-Json)
    $TOKEN = $t.access_token
    if (-not $TOKEN) { throw "Pas de token" }
    Write-Host "Token OK (taille=$($TOKEN.Length))" -ForegroundColor Green
} catch {
    Write-Error "Echec login (401 attendu si mauvais mots de passe)"
    exit 1
}

Write-Host "== /auth/me ==" -ForegroundColor Cyan
$r = Invoke-RestMethod -Method GET -Uri "$Base/auth/me" -Headers @{Authorization="Bearer $TOKEN"}
"User: $($r.username)"

Write-Host "== /debug/secret ==" -ForegroundColor Cyan
$r2 = Invoke-RestMethod -Method GET -Uri "$Base/debug/secret" -Headers @{Authorization="Bearer $TOKEN"}
"Secret: $($r2.secret)"
