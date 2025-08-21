param(
    [string]$OutDir = "docs",
    [string]$OutFile = "openapi.json"
)
$ErrorActionPreference = "Stop"
$env:EXPORT_OPENAPI_DIR = $OutDir
$env:EXPORT_OPENAPI_FILE = $OutFile

# Assumer PYTHONPATH=backend pour import "app"

if (-not $env:PYTHONPATH) { $env:PYTHONPATH = "backend" }
Write-Host "Export OpenAPI -> $OutDir$OutFile" -ForegroundColor Cyan
python -m tools.export_openapi | Out-Null
Write-Host "OK."
