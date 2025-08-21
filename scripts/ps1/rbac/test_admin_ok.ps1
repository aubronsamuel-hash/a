param(
[string]$BaseUrl = "http://localhost:8000",
[string]$Secret = "change_me"
)
$tok = & $PSScriptRoot/make_token.ps1 -Sub "u-admin" -Roles "admin" -Secret $Secret
curl -s -H @{"Authorization" = "Bearer $tok"} "$BaseUrl/admin/ping"
