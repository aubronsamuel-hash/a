if (-not (Get-Command mkdocs -ErrorAction SilentlyContinue)) { Write-Host "mkdocs introuvable" -ForegroundColor Red; exit 2 }
mkdocs gh-deploy --force
if ($LASTEXITCODE -ne 0) { Write-Host "Echec gh-deploy" -ForegroundColor Red; exit 1 }
Write-Host "OK: docs publiees sur gh-pages" -ForegroundColor Green
