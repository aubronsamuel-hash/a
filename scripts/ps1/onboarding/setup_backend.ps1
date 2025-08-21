param(
[string]$Req = "requirements.txt",
[string]$ReqDev = "requirements-dev.txt"
)
Write-Host "== Setup backend ==" -ForegroundColor Cyan
if (Test-Path ".venv/Scripts/Activate.ps1") {
Write-Host ".venv existe deja" -ForegroundColor Yellow
} else {
python -m venv .venv
}
. ".venv/Scripts/Activate.ps1"
pip install -U pip
if (Test-Path $Req) { pip install -r $Req } else { Write-Host "$Req introuvable" -ForegroundColor Yellow }
if (Test-Path $ReqDev) { pip install -r $ReqDev } else { Write-Host "$ReqDev introuvable" -ForegroundColor Yellow }
Write-Host "OK: environnements et deps installes" -ForegroundColor Green
