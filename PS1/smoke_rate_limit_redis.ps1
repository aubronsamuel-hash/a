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
$statuses = @()
for ($i=1; $i -le 20; $i++) { $statuses += (Try-Login "admin" "badpassword") ; Start-Sleep -Milliseconds 50 }
if (-not ($statuses -contains 401)) { Write-Error "Attendu au moins 1 reponse 401" ; exit 1 }
if (-not ($statuses -contains 429)) { Write-Error "Attendu au moins 1 reponse 429 (limite atteinte via Redis)" ; exit 1 }
"Rate limit Redis OK"

