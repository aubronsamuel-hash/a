param([string]$Target = "-1")
$ErrorActionPreference = "Stop"
Write-Host "Alembic downgrade -> $Target" -ForegroundColor Yellow
alembic downgrade $Target
