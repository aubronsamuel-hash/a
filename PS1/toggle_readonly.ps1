param([ValidateSet("on","off")][string]$state = "on")
$ErrorActionPreference = "Stop"
$envFile = ".env"
if (-not (Test-Path $envFile)) { Copy-Item .env.example .env }
$content = Get-Content $envFile
$new = @()
$done = $false
foreach ($line in $content) {
    if ($line -match '^READ_ONLY_MODE=') { $new += "READ_ONLY_MODE=$($state -eq 'on')"; $done=$true } else { $new += $line }
}
if (-not $done) { $new += "READ_ONLY_MODE=$($state -eq 'on')" }
Set-Content $envFile -Value $new -Encoding UTF8
Write-Host "READ_ONLY_MODE -> $state" -ForegroundColor Green
