param(
[string]$Out = ".gitleaks.baseline.json"
)
if (-not (Get-Command gitleaks -ErrorAction SilentlyContinue)) {
    Write-Host "gitleaks introuvable" -ForegroundColor Red; exit 2
}

# Genere une baseline a partir de l'historique actuel (a utiliser ponctuellement)

gitleaks detect --no-banner --redact --report-format json --report-path gitleaks_tmp.json
if ($LASTEXITCODE -ne 0) { Write-Host "Attention: fuites detectees (baseline en construction)"; }

# Convertit vers un baseline minimal compatible

# Ici, on injecte tout le rapport comme baseline (approche conservative)

Copy-Item gitleaks_tmp.json $Out -Force
Remove-Item gitleaks_tmp.json -Force -ErrorAction SilentlyContinue
Write-Host "OK: baseline gitleaks -> $Out" -ForegroundColor Green
