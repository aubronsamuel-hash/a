$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Error "Docker non installe."; exit 1 }
docker volume create cc_cli_pg | Out-Null
$img = "ccapi:local"
if (-not (docker images -q $img)) { docker build -t $img . }

# create OK

docker run --rm -e DB_DSN="postgresql+psycopg://cc:cc@host.docker.internal:5432/ccdb" $img ccadmin create --username alice --password pw

# duplicate KO (exit 1 attendu)

$proc = Start-Process docker -ArgumentList @("run","--rm","-e","DB_DSN=postgresql+psycopg://cc:cc@host.docker.internal:5432/ccdb",$img,"ccadmin","create","--username","alice","--password","pw") -PassThru -Wait
if ($proc.ExitCode -ne 1) { Write-Error "Duplicat doit retourner exit 1 (rc=$($proc.ExitCode))"; exit 1 }
Write-Host "Smoke CLI OK (create OK, duplicat = 1)" -ForegroundColor Green
