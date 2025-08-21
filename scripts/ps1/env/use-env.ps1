param(
    [ValidateSet("dev","staging","prod")] [string]$Env = "dev"
)
$src = ".env.$Env"
if (-not (Test-Path $src)) { Write-Host "Fichier $src introuvable" -ForegroundColor Red; exit 2 }
Copy-Item $src ".env" -Force
[Environment]::SetEnvironmentVariable("ENV", $Env, "Process")
Write-Host "ENV bascule -> $Env (copie $src -> .env)" -ForegroundColor Green
