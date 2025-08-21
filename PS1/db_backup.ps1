param(
    [string]$Dsn = $env:DB_DSN,
    [Parameter(Mandatory=$true)][string]$Out
)
$ErrorActionPreference = "Stop"
if (-not $env:PYTHONPATH) { $env:PYTHONPATH = "backend" }
Write-Host "Backup DB -> $Out" -ForegroundColor Cyan
python -m tools.backup_restore backup --dsn $Dsn --out $Out
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
