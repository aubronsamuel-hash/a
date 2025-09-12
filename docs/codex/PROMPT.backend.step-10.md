# PROMPT.backend.step-10.md
SYSTEM
Tu es un agent CI/DevX. Objectif: stabiliser la CI en corrigeant/encadrant les jobs rouges sans dégrader la qualité. On sépare "bloquants PR" vs "non-bloquants" et on ajoute des garde-fous (labels, paths, env flags) pour que les jobs infra (k6, obs, image scan) ne cassent pas une PR backend simple.

CTX
Checks rouges actuels (exemples):
- backend-tests / backend (push/pr)
- CLI in Docker / cli-docker
- deps-audit / audit
- lint-python / lint
- Load Test (k6) / k6-smoke
- obs-smoke / obs
- Observability Smoke / obs-smoke
- Security Scans / deps-audit
- Security Scans / image-vuln
Checks verts:
- DB Migrations / alembic-sqlite
- OpenAPI Export / export-openapi

GOALS
1) Rendre verts les jobs “backend de base”:
   - backend-tests (pytest + coverage) doit passer (Step-08/09 déjà posés).
   - lint-python doit passer de façon déterministe.
   - alembic-sqlite et openapi restent verts.
2) Encadrer les jobs “infra lourds” (cli-docker, k6, obs, image-vuln, deps-audit):
   - Ne pas bloquer une PR par défaut.
   - Activer ces jobs seulement si:
     a) présents des changements pertinents (paths), ou
     b) on met le label PR: run-infra
   - Sinon: skip proprement (condition `if:` + message clair).
3) Dépôts et sécurité:
   - deps-audit: rendre le job stable avec allowlist minimal + fail-on=auto (fail uniquement sur vulnérabilités HIGH/CRITICAL non ignorées).
   - image-vuln (Trivy): idem via .trivyignore et severity HIGH,CRITICAL (pas FAIL sur MEDIUM/BASIC).
4) Docker CLI:
   - Docker build job: ne s’exécute que si Dockerfile CLI a changé OU label run-infra. Ajouter buildx setup, `--pull`, et `--provenance=false` pour réduire flakiness.
5) Observabilité/k6:
   - k6-smoke: ne s’exécute que si label run-infra OU changements dans `infra/`, `k6/`, `backend/app/**`.
   - obs-smoke: idem (paths), et skip si URLs cible absentes (env vide) au lieu d’échouer.

ACTIONS
A. Lint Python (workflow: .github/workflows/lint-python.yml ou similaire)
- Harmoniser versions outillées:
  - Ajouter/valider dans pyproject.toml:
    [tool.ruff]
    line-length = 100
    target-version = "py311"
  - Et dans workflow: pip install ruff==<version_pin> black==<pin> (ou uniquement ruff si formatage géré ailleurs).
- Faire tourner le lint sur backend/ uniquement par défaut (paths).
- Option: ajouter `--exit-non-zero-on-fix` OFF pour éviter faux rouges si autofix n’est pas appliqué (utiliser check pur).

B. backend-tests (workflow backend_tests.yml)
- Assurer working-directory: backend
- Installer deps test (pytest, pytest-cov, httpx, sqlalchemy si utilisés)
- Commande:
  pytest --cov=app --cov-report=term-missing --cov-fail-under=90
- Si Step-09 n’est pas encore appliqué, ajouter un skip conditionnel:
  - si tests/ vide → échouer proprement avec log “no tests”; sinon exécuter.
  (But: on veut passer les vrais tests; si les tests existent, pas de skip.)

C. deps-audit (pip-audit ou safety)
- Ajouter un fichier allowlist:
  - security/dep-allowlist.txt avec raisons TODO.
- Config job:
  - severity: HIGH,CRITICAL
  - fail-on: new vulns non ignorées
  - upload SARIF en artifact
- Paths/labels:
  - `if:` (contains label `run-infra`) OR changes in `backend/**` or `requirements*.txt`.
  - Sinon skip (conclusion: success avec message “skipped by policy”).

D. Security Scans / image-vuln (Trivy)
- Ajouter `.trivyignore` à la racine avec règles basiques (CVEs connues non actionnables).
- Job:
  - trivy image --severity HIGH,CRITICAL --exit-code 1 --ignorefile .trivyignore
  - activer seulement si Dockerfile ou images concernées changent (paths) OU label run-infra.
  - sinon skip.

E. CLI in Docker / cli-docker
- Preparer buildx + cache-from/to pour stabilité.
- `if:` (label run-infra) OR changes in `cli/**` `Dockerfile*` `docker/**`
- Ajouter `--pull` et `--provenance=false`
- En cas d’absence de Dockerfile: echo et skip, pas d’échec.

F. Load Test (k6) / k6-smoke
- Conditions d’execution:
  - label run-infra OR changes in `k6/**` `infra/**` `backend/app/**`
- Avant d’exécuter: vérifier env K6_BASE_URL. Si absent → skip (success) avec message.
- Temps limites courts (smoke) et seuils tolérants (aucun hard fail si < 1 req/s).

G. Observability Smoke / obs-smoke
- Conditions identiques à k6 (labels/paths).
- Vérifier URLs (PROMETHEUS_URL, GRAFANA_URL, LOKI_URL). Si non fournis → skip success.
- Si fournis: simple GET 200/JSON schema light; sinon mark skipped.

H. OpenAPI Export / DB Migrations
- Conserver tel quel (déjà verts).

I. Required vs Optional
- Convertir “required” (dans repo settings, que tu ne modifies pas) implicitement:
  - Jobs RESTENT required: lint-python, backend-tests, openapi, alembic-sqlite.
  - Jobs NON required au niveau code: on les rend conditionnels (labels/paths) pour éviter l’exécution intempestive.
- Dans les workflows, NE PAS utiliser `continue-on-error: true` sauf dernier recours.

J. Messages clairs
- Chaque job skip doit écrire explicitement:
  “Skipped by CI policy (no relevant changes and no ‘run-infra’ label)”.

K. Commits / PR
- Commits suggérés:
  ci: gate infra jobs by labels/paths and stabilize security scans
  ci(lint): pin tooling and scope to backend
  ci(tests): enforce deterministic backend test run
  security: add .trivyignore and dep allowlist
- PR description: inclure en bas
  Ref: docs/roadmap/step-10.md

ACCEPTANCE CRITERIA
- Les jobs “backend de base” (lint, tests, alembic-sqlite, openapi) passent.
- Les jobs infra (k6, obs, image scan, cli-docker, deps-audit) ne s’exécutent que si pertinents (labels/paths), sinon sont explicitement “skipped” et la PR reste verte.
- Pas de `continue-on-error` global: les erreurs utiles restent visibles quand les jobs sont déclenchés.
- Journaux clairs expliquant skips et conditions.
