$ErrorActionPreference = "Stop"
Write-Host "[INFO] pwsh non detecte. Options:" -ForegroundColor Yellow
Write-Host "  - Windows: .\\PS1\\install_pwsh_on_windows.ps1 (admin, winget/choco)" -ForegroundColor Gray
Write-Host "  - Linux:   sudo bash scripts/bash/install_pwsh.sh" -ForegroundColor Gray
Write-Host "Sinon, utilisez les scripts Bash equivalents (scripts/bash/*.sh)" -ForegroundColor Gray
exit 0
