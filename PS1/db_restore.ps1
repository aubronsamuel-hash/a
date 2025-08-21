param(
    [string]$Dsn = $env:DB_DSN,
    [Parameter(Mandatory=$true)][string]$In,
    [switch]$Overwrite
)
$ErrorActionPreference = "Stop"
if (-not $env:PYTHONPATH) { $env:PYTHONPATH = "backend" }
$ow = @()
if ($Overwrite) { $ow = @("--overwrite") }
Write-Host "Restore DB <- $In" -ForegroundColor Yellow
python -m tools.backup_restore restore --dsn $Dsn --in $In @ow
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
