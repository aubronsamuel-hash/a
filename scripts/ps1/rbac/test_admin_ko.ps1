param(
[string]$BaseUrl = "http://localhost:8000",
[string]$Secret = "change_me"
)
$tok = & $PSScriptRoot/make_token.ps1 -Sub "u-user" -Roles "user" -Secret $Secret
curl -s -D - -o NUL -H @{"Authorization" = "Bearer $tok"} "$BaseUrl/admin/ping"
