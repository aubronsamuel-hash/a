@echo off
REM Lanceur Windows pour la CLI admin. Essaye d'abord PowerShell 7 (pwsh), puis Windows PowerShell.
where pwsh >nul 2>&1
if %errorlevel%==0 (
    pwsh -NoLogo -NoProfile -File "%~dp0..\PS1\ccadmin.ps1" -Command %*
    exit /b %errorlevel%
)
where powershell >nul 2>&1
if %errorlevel%==0 (
    powershell -NoLogo -NoProfile -File "%~dp0..\PS1\ccadmin.ps1" -Command %*
    exit /b %errorlevel%
)
echo [ERREUR] PowerShell non installe. Alternatives:
echo   - Linux/mac: bash scripts\bash\ccadmin.sh list
echo   - Installer PowerShell 7: .\PS1\install_pwsh_on_windows.ps1 (admin)
exit /b 1
