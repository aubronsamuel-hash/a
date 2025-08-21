param(
    [string]$Url = "http://localhost/app.js"
)
Write-Host "Test headers for $Url" -ForegroundColor Cyan
$response = curl -s --compressed -D - -o NUL $Url
$response | Select-String -Pattern "Cache-Control"
$response | Select-String -Pattern "ETag"
$response | Select-String -Pattern "Content-Encoding"
