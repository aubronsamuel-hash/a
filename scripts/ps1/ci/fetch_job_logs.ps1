param(
    [string]$Repo = $env:GITHUB_REPOSITORY,
    [string]$RunId
)
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Host "gh introuvable" -ForegroundColor Red; exit 2 }
if (-not $Repo) { Write-Host "GITHUB_REPOSITORY non defini" -ForegroundColor Red; exit 3 }
if (-not $RunId) { Write-Host "RunId requis" -ForegroundColor Red; exit 4 }
$dest = ".ci\logs\$RunId"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Write-Host "== Telecharge logs run $RunId ==" -ForegroundColor Cyan
gh run view $RunId -R $Repo --log > "$dest\run.log"
gh run download $RunId -R $Repo -D "$dest" 2>$null
Write-Host "OK: logs dans $dest" -ForegroundColor Green
