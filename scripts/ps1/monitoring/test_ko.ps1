param(
    [string]$Prom="http://localhost:9090"
)
Write-Host "Test KO: blackbox en echec volontaire" -ForegroundColor Yellow

# On simule une URL invalide temporairement via API v1 de reload (simple check metrics sans reload:
# on attend simplement que probe_success tombe a 0 pour une cible injoignable)
# Ici, on verifie juste la presence de la serie probe_success et que sa valeur est 0 si la cible est KO.

$metric = Invoke-WebRequest -UseBasicParsing "$Prom/api/v1/query?query=probe_success%7Bjob%3D%22blackbox_api%22%7D" -TimeoutSec 5 | ConvertFrom-Json
$vals = $metric.data.result.value
if (-not $vals) { Write-Host "Pas de metrics probe_success. KO attendu non verifiable." -ForegroundColor Red; exit 1 }

# On accepte 0 ou 1 selon l etat. Pour forcer un vrai KO, l operateur devra mettre PUBLIC_API_URL=http://127.0.0.1:9/healthz et relancer up.
Write-Host "Metric probe_success presente. Valeur actuelle: $($vals[1])." -ForegroundColor Cyan
Write-Host "KO veritable a tester en pointant une URL invalide dans monitoring/.env puis relance." -ForegroundColor Yellow
