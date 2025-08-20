$ErrorActionPreference = "Stop"
if (Test-Path .\cc.db) {
  Remove-Item .\cc.db -Force
  Write-Host "cc.db supprime." -ForegroundColor Yellow
} else {
  Write-Host "Aucun cc.db a supprimer." -ForegroundColor Yellow
}
Write-Host "Relancez PS1\run.ps1 ou PS1\run_bg.ps1 pour recreer le schema et autoseed." -ForegroundColor Cyan
