Param(
    [string]$PythonExe = "python"
)
$ErrorActionPreference = "Stop"

Write-Host "Creation venv..." -ForegroundColor Cyan
& $PythonExe -m venv .venv
if ($LASTEXITCODE -ne 0) { Write-Error "Echec creation venv" ; exit 1 }

$Vpy = ".\.venv\Scripts\python.exe"
$Pip = ".\.venv\Scripts\pip.exe"

Write-Host "Upgrade pip (via python -m)..." -ForegroundColor Cyan
& $Vpy -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { Write-Error "Echec upgrade pip" ; exit 1 }

Write-Host "Installation des dependances (editable)..." -ForegroundColor Cyan
& $Pip install -e backend[dev]
if ($LASTEXITCODE -ne 0) { Write-Error "Echec installation deps" ; exit 1 }

Write-Host "OK: environnement pret." -ForegroundColor Green
