# Monitoring / Healthchecks

* /healthz: repond toujours 200 {status: ok}
* /readyz: check DB (SELECT 1). 200 {status: ready} si OK, sinon 503 {status: db_error}

Scripts:

* Windows: .\scripts\ps1\health\test_health.ps1
* Bash: ./scripts/bash/health/test_health.sh
