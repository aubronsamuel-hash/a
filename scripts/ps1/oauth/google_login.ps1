param(
    [string]$BaseUrl = "http://localhost:8000"
)
$start = "$BaseUrl/auth/google/start"
Write-Host "Ouverture du navigateur: $start" -ForegroundColor Cyan
Start-Process $start | Out-Null
