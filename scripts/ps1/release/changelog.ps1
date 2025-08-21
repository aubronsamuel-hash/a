param(
    [string]$Version,
    [string]$Header = "# Changelog"
)
if (-not $Version) { $Version = (& $PSScriptRoot/get_version.ps1) }
$today = (Get-Date).ToString("yyyy-MM-dd")
$since = (git describe --tags --abbrev=0 2>$null)
if (-not $since) {
    $log = git log --pretty=format:"%s|||%h" --no-merges
} else {
    $log = git log "$since..HEAD" --pretty=format:"%s|||%h" --no-merges
}

# Regroupement simple par type (feat, fix, perf, chore)

$groups = @{feat=@();fix=@();perf=@();chore=@();docs=@();refactor=@();test=@();ci=@()}
foreach ($line in $log) {
    if (-not $line) { continue }
    $p = $line -split '|||'
    $msg = $p[0]; $sha = $p[1]
    $key = ($msg -split "[:(]" | Select-Object -First 1).ToLower()
    if (-not $groups.ContainsKey($key)) { $key = "chore" }
    $groups[$key] += "- $msg ($sha)"
}
$section = @()
$section += "## [$Version] - $today"
foreach ($k in "feat","fix","perf","refactor","docs","test","ci","chore") {
    $items = $groups[$k]
    if ($items -and $items.Count -gt 0) {
        $section += "### $k"
        $section += $items
    }
}
$body = ($section -join "`n") + "`n`n"
$ch = "CHANGELOG.md"
if (-not (Test-Path $ch)) { Set-Content $ch $Header -Encoding UTF8 }
Add-Content $ch "`n$body"
Write-Host "OK: CHANGELOG mis a jour pour $Version" -ForegroundColor Green
