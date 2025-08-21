param([string]$Path=".")
if (-not (Get-Command ruff -ErrorAction SilentlyContinue)) {
Write-Host "ruff introuvable. Installer: pip install ruff" -ForegroundColor Red; exit 2
}
ruff check $Path
