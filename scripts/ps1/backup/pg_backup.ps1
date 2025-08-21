param(
    [string]$BackupDir = "backups/db",
    [int]$RetentionDays = 7,
    [string]$DbHost = $env:DB_HOST,
    [int]$Port = [int]($env:DB_PORT),
    [string]$Db = $env:DB_NAME,
    [string]$User = $env:DB_USER,
    [string]$Password = $env:DB_PASSWORD
)

Write-Host "== Backup DB ==" -ForegroundColor Cyan
if (-not $DbHost) { $DbHost = "localhost" }
if (-not $Port) { $Port = 5432 }
if (-not $Db) { Write-Host "DB_NAME manquant" -ForegroundColor Red; exit 2 }
if (-not $User) { Write-Host "DB_USER manquant" -ForegroundColor Red; exit 2 }
if (-not $Password) { Write-Host "DB_PASSWORD manquant" -ForegroundColor Red; exit 2 }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$dest = Join-Path $BackupDir (Get-Date -Format "yyyy\MM-dd")
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$outFile = Join-Path $dest ("${Db}_${ts}.sql.gz")

function Test-Docker {
    try { docker --version | Out-Null; return $true } catch { return $false }
}

 $env:PGPASSWORD = $Password
 if (Test-Docker) {
    Write-Host "Docker detecte: utilisation de postgres:16 pour pg_dump" -ForegroundColor Green
    $cmd = @(
        "run","--rm",
        "-e","PGPASSWORD=$Password",
        "-v", (Resolve-Path $dest).Path + ":/dump",
        "postgres:16",
        "bash","-lc",
        "pg_dump -h $DbHost -p $Port -U $User $Db | gzip -c > /dump/$(Split-Path -Leaf $outFile)"
    )
    $p = Start-Process -FilePath docker -ArgumentList $cmd -NoNewWindow -PassThru -Wait
    if ($p.ExitCode -ne 0) { Write-Host "Echec pg_dump via docker (code $($p.ExitCode))" -ForegroundColor Red; exit 3 }
 } else {
    Write-Host "Docker absent, tentative pg_dump local" -ForegroundColor Yellow
    $pgdump = "pg_dump"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $pgdump
    $psi.Arguments = "-h $DbHost -p $Port -U $User $Db"
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $psi.EnvironmentVariables["PGPASSWORD"] = $Password
    $p = [System.Diagnostics.Process]::Start($psi)
    $p.WaitForExit()
    if ($p.ExitCode -ne 0) { Write-Host "Echec pg_dump local (code $($p.ExitCode))" -ForegroundColor Red; exit 3 }

    # Compression .gz via .NET

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($p.StandardOutput.ReadToEnd())
    $fs = [System.IO.File]::Create($outFile)
    $gzip = New-Object System.IO.Compression.GzipStream($fs, [System.IO.Compression.CompressionLevel]::Optimal)
    $gzip.Write($bytes, 0, $bytes.Length)
    $gzip.Close(); $fs.Close()
}

# Verif

if (-not (Test-Path $outFile)) { Write-Host "Backup absent" -ForegroundColor Red; exit 4 }
if ((Get-Item $outFile).Length -lt 512) { Write-Host "Backup trop petit" -ForegroundColor Red; exit 5 }
Write-Host "OK: $outFile" -ForegroundColor Green

# Retention

Get-ChildItem -Recurse $BackupDir -Filter "*.sql.gz" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Host "Retention appliquee ($RetentionDays j)" -ForegroundColor Cyan
