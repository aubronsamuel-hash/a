param(
    [string]$BaseUrl = "http://localhost:8000",
    [string]$MetricsPath = "/metrics"
)
Write-Host "== Test metrics OK ==" -ForegroundColor Cyan

# Fait une requete pour peupler

curl -s -o NUL "$BaseUrl/healthz" | Out-Null
$response = curl -s -D - -o NUL "$BaseUrl$MetricsPath"
$response | Select-String -Pattern "200"
$response | Select-String -Pattern "text/plain"
