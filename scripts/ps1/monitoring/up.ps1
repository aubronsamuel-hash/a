param(
    [string]$EnvFile = "monitoring/.env"
)
Write-Host "Chargement env depuis $EnvFile" -ForegroundColor Cyan
if (Test-Path $EnvFile) { Get-Content $EnvFile | foreach {
    if ($_ -match "^\s*$") { return }
    if ($_ -match "^\s*#") { return }
    $k,$v = $_.Split("=",2)
    $env:$k = $v
}}
docker compose -f monitoring/docker-compose.monitoring.yml up -d
Write-Host "Stack monitoring demarree." -ForegroundColor Green
