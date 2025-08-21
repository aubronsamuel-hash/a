# Monitoring

* Prometheus: scrape `/metrics` (voir etape 45)
* Grafana: dashboards provisionnes (voir etape 38)
* Alertes: Alertmanager (routes par defaut)

## Checks

* `probe_success{job="blackbox_api"}` == 1
* p95 latence < 500ms
