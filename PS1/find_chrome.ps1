$ErrorActionPreference = "SilentlyContinue"
$paths = @(
  (Get-Command chrome -ErrorAction SilentlyContinue).Path,
  "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "$Env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
) | Where-Object { $_ -and (Test-Path $_) }
if ($paths -and $paths[0]) { Write-Output $paths[0]; exit 0 } else { exit 1 }
