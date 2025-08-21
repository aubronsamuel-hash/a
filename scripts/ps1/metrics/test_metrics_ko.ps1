param(
    [string]$BaseUrl = "http://localhost:8000",
    [string]$MetricsPath = "/metrics"
)
Write-Host "== Test metrics KO (disabled) ==" -ForegroundColor Yellow
$response = curl -s -D - -o NUL "$BaseUrl$MetricsPath"
$response  # doit montrer 404 si desactive
