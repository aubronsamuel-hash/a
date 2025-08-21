param(
    [int]$Cpu = 0,
    [int]$Max = 12
)
if ($Cpu -le 0) { $Cpu = [int]([Environment]::ProcessorCount) }
$calc = (2 * $Cpu) + 1
$workers = [Math]::Max(3, [Math]::Min($calc, $Max))
Write-Host "CPU=$Cpu -> WEB_CONCURRENCY=$workers" -ForegroundColor Cyan
$workers
