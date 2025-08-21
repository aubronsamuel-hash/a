# Prometheus Metrics

* Activation: METRICS_ENABLED=1 (default)
* Endpoint: METRICS_PATH=/metrics (configurable)
* Contenu: metriques HTTP (compteurs, latences), exportees en text/plain pour Prometheus.

Tests:

* Unitaires: PYTHONPATH=backend pytest -q backend/tests/test_metrics.py (2 passed)
* Scripts:

  * Windows: .\scripts\ps1\metrics\test_metrics_ok.ps1
  * Bash: ./scripts/bash/metrics/test_metrics_ok.sh

Usage Prometheus:

* Ajouter une job dans Prometheus:
  job_name: api
  static_configs:
  * targets: ["host:port"]
    metrics_path: /metrics
