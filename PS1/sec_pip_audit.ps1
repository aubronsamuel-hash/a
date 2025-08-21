$ErrorActionPreference = "Stop"
param(
    [string]$Output = "reports\pip-audit.sarif",
    [string]$Format = "sarif"
)
Write-Host "Analyse dependances Python (pip-audit)..." -ForegroundColor Cyan
python -m pip install --upgrade pip > $null
python -m pip install pip-audit cyclonedx-bom > $null

# Installer les deps du projet (dev) si pas deja fait

python -m pip install -e backend[dev] > $null
New-Item -ItemType Directory -Force -Path (Split-Path $Output) | Out-Null
pip-audit -r backend/requirements.txt 2>$null | Out-Null

# Si requirements.txt n existe pas, auditer l env courant (wheel installe)

pip-audit -f $Format -o $Output || exit $LASTEXITCODE
Write-Host "pip-audit termine. Rapport: $Output" -ForegroundColor Green
