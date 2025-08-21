param(
    [ValidateSet("patch","minor","major")][string]$Level = "patch",
    [switch]$PushTags
)
& $PSScriptRoot/bump.ps1 -Level $Level
$ver = & $PSScriptRoot/get_version.ps1
& $PSScriptRoot/changelog.ps1 -Version $ver
& git add VERSION CHANGELOG.md backend/app/__init__.py
& git commit -m "chore(release): v$ver"
& $PSScriptRoot/tag.ps1 -Version $ver
if ($PushTags) { & $PSScriptRoot/push.ps1 -Tags }
