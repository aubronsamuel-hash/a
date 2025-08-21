$ErrorActionPreference = "Stop"
param(
    [Parameter(Mandatory=$true)][ValidateSet("list","create","promote","reset-password")] [string]$Command,
    [string]$Username,
    [string]$Password,
    [string]$Role = "user",
    [string]$NewPassword,
    [string]$Image = "ccapi:local",
    [string]$Volume = "ccapi_cli_data"
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker non installe. Installez Docker Desktop ou utilisez les scripts Bash locaux."
    exit 1
}

# Build si l image n existe pas

$exists = (docker images -q $Image)
if (-not $exists) {
    Write-Host "Image $Image absente. Construction..." -ForegroundColor Yellow
    docker build -t $Image .
}

# Volume persistant pour la DB

docker volume create $Volume | Out-Null

# Construire la ligne de commande ccadmin

$baseArgs = @("run","--rm","-e","DB_DSN=sqlite:////data/cc.db","-v","$Volume:/data",$Image,"ccadmin")
switch ($Command) {
    "list"           { $args = $baseArgs + @("list") }
    "create"         { $args = $baseArgs + @("create","--username",$Username,"--password",$Password,"--role",$Role) }
    "promote"        { $args = $baseArgs + @("promote","--username",$Username) }
    "reset-password" { $args = $baseArgs + @("reset-password","--username",$Username,"--new-password",$NewPassword) }
}

# Executer

$proc = Start-Process docker -ArgumentList $args -NoNewWindow -PassThru -Wait
exit $proc.ExitCode
