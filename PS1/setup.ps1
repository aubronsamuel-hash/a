Param([string]$PythonExe = "python")
$ErrorActionPreference = "Stop"
Write-Host "Creation venv..." -ForegroundColor Cyan
& $PythonExe -m venv .venv
if ($LASTEXITCODE -ne 0) { Write-Error "Echec creation venv" ; exit 1 }
$Vpy = ".venv\Scripts\python.exe"
$Pip = ".venv\Scripts\pip.exe"
& $Vpy -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { Write-Error "Echec upgrade pip" ; exit 1 }
& $Pip install -e backend[dev]
if ($LASTEXITCODE -ne 0) { Write-Error "Echec installation deps" ; exit 1 }
Write-Host "OK: environnement pret." -ForegroundColor Green
