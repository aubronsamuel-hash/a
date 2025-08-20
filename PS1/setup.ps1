Param(
    [string]$PythonExe = "python"
)
$ErrorActionPreference = "Stop"
Write-Host "Creation venv..." -ForegroundColor Cyan
& $PythonExe -m venv .venv
if ($LASTEXITCODE -ne 0) { Write-Error "Echec creation venv" ; exit 1 }
.\.venv\Scripts\pip.exe install -U pip
if ($LASTEXITCODE -ne 0) { Write-Error "Echec upgrade pip" ; exit 1 }
.\.venv\Scripts\pip.exe install -e backend[dev]
if ($LASTEXITCODE -ne 0) { Write-Error "Echec installation deps" ; exit 1 }
Write-Host "OK: environnement pret." -ForegroundColor Green
