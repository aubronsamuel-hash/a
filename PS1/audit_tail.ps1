param([string]$Path = "audit.jsonl")
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Path)) { New-Item -ItemType File -Path $Path -Force | Out-Null }
Write-Host "Suivi du journal: $Path (CTRL+C pour stopper)" -ForegroundColor Cyan
Get-Content -Path $Path -Tail 100 -Wait
