param([string]$Target = "head")
$ErrorActionPreference = "Stop"
Write-Host "Alembic upgrade -> $Target" -ForegroundColor Cyan
alembic upgrade $Target
