param([string]$Version)
if (-not $Version) { $Version = (& $PSScriptRoot/get_version.ps1) }

# Verif repo propre

& git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { Write-Host "Arbre Git sale. Committez ou stash avant de tag." -ForegroundColor Red; exit 3 }
$tag = "v$Version"
$exists = git rev-parse -q --verify "refs/tags/$tag" 2>$null
if ($LASTEXITCODE -eq 0) { Write-Host "Tag deja existant: $tag" -ForegroundColor Yellow; exit 0 }

# Utilise derniere section du CHANGELOG en message

$body = (Get-Content CHANGELOG.md -Raw)
$msg = "Release $tag"
if ($body) { $msg = ($body -split "## \[")[-1]; $msg = "Release $tag" }
& git tag -a $tag -m "Release $tag"
if ($LASTEXITCODE -ne 0) { Write-Host "Echec creation tag" -ForegroundColor Red; exit 4 }
Write-Host "OK: tag $tag cree" -ForegroundColor Green
