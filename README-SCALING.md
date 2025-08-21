# Scalabilite Gunicorn

Formule workers: (2*CPU)+1 borne [3..12] par defaut. Overridable via WEB_CONCURRENCY.
Timeout=30s, Graceful=30s, KeepAlive=5s, MaxRequests=500(+50 jitter).

Demarrage local (Windows):

* .\scripts\ps1\scaling\start.ps1
* Ouvrir http://localhost:8000/healthz -> 200

Test metadata:

* Invoke-RestMethod http://localhost:8000/_meta/scaling

Docker:

* docker compose -f docker/docker-compose.override.yml up -d api

Reload:

* .\scripts\ps1\scaling\reload.ps1 (best-effort Windows) ou relance service
