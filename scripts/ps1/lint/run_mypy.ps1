param([string]$Path="backend")
if (-not (Get-Command mypy -ErrorAction SilentlyContinue)) {
Write-Host "mypy introuvable. Installer: pip install mypy" -ForegroundColor Red; exit 2
}
mypy $Path
