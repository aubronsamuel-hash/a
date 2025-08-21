# Monitoring (Prometheus, Alertmanager, Grafana, Blackbox, cAdvisor)

Prerequis:

* Docker Desktop
* Fichier monitoring/.env base sur .env.example

Demarrage:

* PowerShell:
  .\scripts\ps1\monitoring\up.ps1 -EnvFile monitoring/.env
* Bash:
  ./scripts/bash/monitoring/up.sh monitoring/.env

Acces:

* Prometheus: http://localhost:9090
* Alertmanager: http://localhost:9093
* Grafana: http://localhost:3000 (admin/admin par defaut, a changer)
* Blackbox exporter: http://localhost:9115/metrics
* cAdvisor: http://localhost:8080

Test OK:

* .\scripts\ps1\monitoring\test_ok.ps1

Test KO (manuel force):

* Editer monitoring/.env -> PUBLIC_API_URL=http://127.0.0.1:9/healthz
* Redemarrer la stack (down puis up)
* Sur Prometheus, la requete probe_success{job="blackbox_api"} doit valoir 0.

Notes:

* Aucune alerte n envoie de notification par defaut (receiver null). Ajouter une integration (email/telegram) en prod.
* Retention Prometheus par defaut; ajuster via flags si besoin.
