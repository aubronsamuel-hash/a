param(
    [Parameter(Mandatory=$true)][ValidateSet("major","minor","patch")] [string]$Part,
    [switch]$Tag,
    [switch]$BuildDocker,
    [string]$DockerImage = "ccapi"
)
$ErrorActionPreference = "Stop"

function Get-Version {
    $verPy = (Get-Content "backend/app/version.py" -Raw) -match "version = ['"]([^'"]+)['"]" | Out-Null
    if (-not $Matches[1]) { throw "Version introuvable dans backend/app/version.py" }
    return $Matches[1]
}
function Set-VersionFiles([string]$new) {
    # version.py
    (Get-Content "backend/app/version.py") -replace 'version = ["''][^"'']+["'']', "version = '$new'" | Set-Content "backend/app/version.py" -Encoding UTF8
    # pyproject.toml
    (Get-Content "backend/pyproject.toml") -replace '(^version = ")([^"]+)(")', "`$1$new`$3" | Set-Content "backend/pyproject.toml" -Encoding UTF8
}
function Next-Version([string]$v, [string]$part) {
    if ($v -notmatch '^\d+\.\d+\.\d+$') { throw "Version non SemVer: $v" }
    $maj,$min,$pat = $v.Split(".")
    switch ($part) {
        "major" { return "$([int]$maj+1).0.0" }
        "minor" { return "$maj.$([int]$min+1).0" }
        "patch" { return "$maj.$min.$([int]$pat+1)" }
    }
}

$curr = Get-Version
$next = Next-Version $curr $Part
Write-Host "Version actuelle: $curr -> nouvelle: $next" -ForegroundColor Cyan

# MAJ fichiers
Set-VersionFiles $next

# MAJ CHANGELOG (section Unreleased -> version avec date)
$today = (Get-Date).ToString("yyyy-MM-dd")
$ch = Get-Content "CHANGELOG.md" -Raw
if ($ch -notmatch "## \[Unreleased\]") { $ch = "## [Unreleased]`n`n$ch" }
$ch = $ch -replace "## \[Unreleased\]", "## [Unreleased]`n`n## [$next] - $today"
Set-Content "CHANGELOG.md" -Value $ch -Encoding UTF8

# Git commit + tag optionnels
git add backend/app/version.py backend/pyproject.toml CHANGELOG.md | Out-Null
git commit -m "chore(release): bump version to $next" | Out-Null
if ($Tag) {
    git tag "v$next"
    Write-Host "Tag cree: v$next" -ForegroundColor Green
}

# Build Docker optionnel
if ($BuildDocker) {
    docker build -t "$DockerImage:latest" -t "$DockerImage:$next" .
    Write-Host "Images construites: $DockerImage:latest et :$next" -ForegroundColor Green
}

Write-Host "OK. Prochaine version: $next" -ForegroundColor Green
