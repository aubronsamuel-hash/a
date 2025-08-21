param(
    [Parameter(Mandatory=$true)][string]$Version,
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"

# 1) Valider SemVer
if (-not ($Version -match '^\d+\.\d+\.\d+$')) { Write-Error "Version invalide (attendu X.Y.Z)"; exit 1 }

# 2) Mettre a jour version.py et pyproject.toml
$verFile = "backend/app/version.py"
$projFile = "backend/pyproject.toml"
if (-not (Test-Path $verFile)) { Write-Error "Fichier $verFile introuvable"; exit 1 }
if (-not (Test-Path $projFile)) { Write-Error "Fichier $projFile introuvable"; exit 1 }

(Get-Content $verFile) -replace '^version\s*=\s*".*"$', "version = `"$Version`"" | Set-Content $verFile -Encoding UTF8
(Get-Content $projFile) -replace '^version\s*=\s*".*"$', "version = `"$Version`"" | Set-Content $projFile -Encoding UTF8

# 3) Lints + tests
python -m ruff check backend
python -m mypy backend
pytest -q --cov=backend

# 4) Commit + tag + push
git add $verFile $projFile
$commitMsg = "chore(release): v$Version"
if ($DryRun) {
    Write-Host "[DRYRUN] git commit -m `"$commitMsg`""
    Write-Host "[DRYRUN] git tag v$Version -a -m `"release v$Version`""
    Write-Host "[DRYRUN] git push && git push --tags"
    exit 0
}

git commit -m $commitMsg
git tag "v$Version" -a -m "release v$Version"
git push
git push --tags
Write-Host "Release v$Version creee et poussee." -ForegroundColor Green
