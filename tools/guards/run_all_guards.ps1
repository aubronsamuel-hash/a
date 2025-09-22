param(
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$guards = @(
    "commit_guard.ps1",
    "roadmap_guard.ps1",
    "docs_guard.ps1"
)

foreach ($guard in $guards) {
    $guardPath = Join-Path $scriptDir $guard
    if (-not (Test-Path -LiteralPath $guardPath)) {
        Write-Host ("run_all_guards: skip {0} (missing)" -f $guard)
        continue
    }

    $args = @()
    if ($Strict) { $args += "--strict" }

    Write-Host ("run_all_guards: running {0}" -f $guard)
    & $guardPath @args
}

Write-Host "run_all_guards OK"
