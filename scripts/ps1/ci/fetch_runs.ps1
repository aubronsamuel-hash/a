param(
    [string]$Repo = $env:GITHUB_REPOSITORY,
    [int]$Limit = 10
)
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Host "GitHub CLI (gh) introuvable. Installer: https://cli.github.com/" -ForegroundColor Red; exit 2 }
if (-not $Repo) { Write-Host "GITHUB_REPOSITORY non defini (ex: org/repo)" -ForegroundColor Yellow; exit 3 }
New-Item -ItemType Directory -Force -Path .ci\logs | Out-Null
Write-Host "== Liste des derniers runs ($Repo) ==" -ForegroundColor Cyan
gh run list -R $Repo -L $Limit | Tee-Object .ci\logs\runs.txt
Write-Host "OK: .ci\logs\runs.txt" -ForegroundColor Green
