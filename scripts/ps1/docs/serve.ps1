param(
[int]$Port = [int]([Environment]::GetEnvironmentVariable("DOCS_PORT","Process") ?? 8001)
)
if (-not (Get-Command mkdocs -ErrorAction SilentlyContinue)) { Write-Host "mkdocs introuvable. Installer via 'pip install -r requirements-docs.txt'" -ForegroundColor Red; exit 2 }
Write-Host "Demarrage serveur docs sur :$Port" -ForegroundColor Cyan
mkdocs serve -a 0.0.0.0:$Port
