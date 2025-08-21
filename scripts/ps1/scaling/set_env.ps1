param(
    [int]$Cpu = 0,
    [int]$Max = 12,
    [int]$Timeout = 30,
    [int]$Graceful = 30,
    [int]$KeepAlive = 5
)
$workers = & $PSScriptRoot/calc_workers.ps1 -Cpu $Cpu -Max $Max
[System.Environment]::SetEnvironmentVariable("WEB_CONCURRENCY", "$workers", "Process")
[System.Environment]::SetEnvironmentVariable("GUNICORN_TIMEOUT", "$Timeout", "Process")
[System.Environment]::SetEnvironmentVariable("GUNICORN_GRACEFUL_TIMEOUT", "$Graceful", "Process")
[System.Environment]::SetEnvironmentVariable("GUNICORN_KEEPALIVE", "$KeepAlive", "Process")
Write-Host "Env set: WEB_CONCURRENCY=$workers, TIMEOUT=$Timeout, GRACEFUL=$Graceful, KEEPALIVE=$KeepAlive" -ForegroundColor Green
