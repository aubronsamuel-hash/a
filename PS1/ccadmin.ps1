param(
    [Parameter(Mandatory=$true)][ValidateSet("list","create","promote","reset-password")] [string]$Command,
    [string]$Username,
    [string]$Password,
    [string]$Role,
    [string]$NewPassword
)
$ErrorActionPreference = "Stop"

# Utilise le binaire installe par pip (console_scripts) si dispo, sinon fallback python -m
function Invoke-CCAdmin {
    param([string[]]$Args)
    try { & ccadmin @Args ; return } catch { }
    python -m app.cli @Args
}
switch ($Command) {
    "list"           { Invoke-CCAdmin @("list") }
    "create"         { Invoke-CCAdmin @("create","--username",$Username,"--password",$Password, @("--role",$Role) ) }
    "promote"        { Invoke-CCAdmin @("promote","--username",$Username) }
    "reset-password" { Invoke-CCAdmin @("reset-password","--username",$Username,"--new-password",$NewPassword) }
}
