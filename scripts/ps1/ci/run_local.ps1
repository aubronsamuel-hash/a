param(
    [string]$Job = "backend-tests"
)
$map = Import-Csv .ci\repro_matrix.csv
$entry = $map | Where-Object { $_.job -eq $Job }
if (-not $entry) { Write-Host "Job inconnu: $Job" -ForegroundColor Red; exit 2 }
$cmd = $entry.local_cmd
Write-Host "== Repro locale: $Job ==" -ForegroundColor Cyan
Write-Host $cmd -ForegroundColor Gray

# Tente via PowerShell

try {
    if ($cmd.StartsWith("PYTHONPATH=")) {
        $parts = $cmd.Split(" ",2)
        $envK,$rest = $parts[0],$parts[1]
        $kv = $envK.Split("=")
        $env:PYTHONPATH = $kv[1]
        Invoke-Expression $rest
    } else {
        Invoke-Expression $cmd
    }
} catch {
    Write-Host "Echec commande: $cmd" -ForegroundColor Red
    exit 3
}
