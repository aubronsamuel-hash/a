# Provoque un mkdocs.yml invalide et attend un echec, puis restaure

$backup = Get-Content mkdocs.yml -Raw
"site_name: \n  - mauvais: [" | Set-Content -Encoding UTF8 mkdocs.yml
pip install -q -r requirements-docs.txt
mkdocs build --clean
if ($LASTEXITCODE -eq 0) { Write-Host "KO: build aurait du echouer" -ForegroundColor Red; Set-Content -Encoding UTF8 mkdocs.yml $backup; exit 1 }
Write-Host "OK: echec attendu (config invalide)" -ForegroundColor Yellow
Set-Content -Encoding UTF8 mkdocs.yml $backup
