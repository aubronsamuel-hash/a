Param(
    [string]$PythonExe = "python"
)
$ErrorActionPreference = "Stop"
Write-Host "Creation venv..." -ForegroundColor Cyan
& $PythonExe -m venv .venv
.\.venv\Scripts\pip.exe install -U pip
.\.venv\Scripts\pip.exe install -e backend[dev]
Write-Host "OK: environnement pret." -ForegroundColor Green
