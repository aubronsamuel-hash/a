param(
    [ValidateSet("patch","minor","major")][string]$Level = "patch",
    [string]$Set
)
function Parse-Semver($v){
    if ($v -notmatch '^(\d+)\.(\d+)\.(\d+)') { throw "Semver invalide: $v" }
    return [int]$Matches[1],[int]$Matches[2],[int]$Matches[3]
}
if ($Set) { & $PSScriptRoot/set_version.ps1 -Version $Set; exit $LASTEXITCODE }
$cur = & $PSScriptRoot/get_version.ps1
$maj,$min,$pat = Parse-Semver $cur
switch ($Level) {
    "patch" { $pat++ }
    "minor" { $min++; $pat=0 }
    "major" { $maj++; $min=0; $pat=0 }
}
$new = "$maj.$min.$pat"
& $PSScriptRoot/set_version.ps1 -Version $new
