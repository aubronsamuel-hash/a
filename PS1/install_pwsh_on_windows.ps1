$ErrorActionPreference = "Stop"
Write-Host "Installation de PowerShell 7 sur Windows" -ForegroundColor Cyan

# 1) winget (recommande)
try {
    winget --version | Out-Null
    Write-Host "winget detecte. Installation..." -ForegroundColor Yellow
    winget install --id Microsoft.PowerShell -e --source winget --accept-package-agreements --accept-source-agreements
    Write-Host "PowerShell 7 installe via winget." -ForegroundColor Green
    pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion'
    exit 0
} catch {
    Write-Warning "winget non disponible ou echec."
}

# 2) Chocolatey (alternative)
try {
    choco --version | Out-Null
    Write-Host "Chocolatey detecte. Installation..." -ForegroundColor Yellow
    choco install powershell-core -y
    Write-Host "PowerShell 7 installe via Chocolatey." -ForegroundColor Green
    pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion'
    exit 0
} catch {
    Write-Warning "Chocolatey non disponible."
}
Write-Warning "Ni winget ni choco detecte. Installer manuellement: https://aka.ms/powershell"
