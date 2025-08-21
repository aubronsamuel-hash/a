$ErrorActionPreference = "Stop"
param(
    [string]$Output = "reports\pip-audit.sarif"
)
Write-Host "Analyse des dependances Python (pip-audit)..." -ForegroundColor Cyan
python -m pip install --upgrade pip > $null
python -m pip install pip-audit cyclonedx-bom > $null

# Installer deps projet (dev) si non deja fait
python -m pip install -e backend[dev] > $null
New-Item -ItemType Directory -Force -Path (Split-Path $Output) | Out-Null

# Si un requirements existe, l'auditer silencieusement (ne bloque pas si absent)
if (Test-Path "backend\requirements.txt") {
    pip-audit -r backend\requirements.txt | Out-Null
}
pip-audit -f sarif -o $Output
Write-Host "pip-audit OK -> $Output" -ForegroundColor Green
