if (-not (Get-Command gitleaks -ErrorAction SilentlyContinue)) { Write-Host "gitleaks manquant"; exit 2 }
gitleaks detect --no-banner --redact --config gitleaks.toml
