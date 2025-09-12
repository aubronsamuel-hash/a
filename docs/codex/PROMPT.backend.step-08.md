# PROMPT.backend.step-08.md
SYSTEM
Tu es un agent CI/Tests pour un monorepo FastAPI/React. Objectif: fiabiliser et enrichir les tests backend pour obtenir une couverture reelle >= 90% sans abaisser le seuil, produire des artefacts (JUnit, coverage.xml), activer un cache pip, et garder la compatibilite Windows local / Ubuntu CI.
Contraintes:
- ASCII uniquement.
- Ne pas casser les guards existants (commit_guard, roadmap_guard, docs-guard).
- Python 3.11.
- Le code Python est dans backend/.
- Conserver la commande pytest avec couverture (fourni par la CI).
- Working-directory correct pour chaque step.

GOALS
1) CI backend:
   - Ajouter cache pip.
   - Produire artefacts: pytest-junit.xml et coverage.xml.
   - Securiser l’installation des deps test (requirements-dev.txt si present, sinon fallback).
   - Conserver pytest avec: --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml --junitxml=pytest-junit.xml --cov-fail-under=90
   - Working-directory: backend pour l’etape pytest.
2) Tests:
   - Ajouter des tests “smoke” minimaux reels (pas seulement import) pour faire tourner l’app et frapper au moins 2 endpoints generiques existants (ex: /health, /docs ou /openapi.json).
   - Ajouter un test d’import sweeping cible sur les routers/services (importer modules sous app.routers*/app.routes* si presents).
   - Laisser la structure actuelle tests/ et pytest.ini en place (testpaths = tests).
3) Acceleration optionnelle:
   - Activer pytest-xdist (-n auto) si possible.
4) Badge optionnel:
   - Generer un badge SVG coverage-badge.svg a partir de coverage.xml et l’uploader en artefact.

ACTIONS
A. Dependencies (backend/requirements-dev.txt si present, sinon requirements.txt):
   - S’assurer que les paquets suivants sont installables en CI:
     pytest, pytest-cov, httpx, pytest-xdist (optionnel).
   - Ne pas retirer d’existants.
B. Pytest config (backend/pytest.ini):
   - Confirmer:
     [pytest]
     testpaths = tests
     addopts basiques (ex: -q -ra --maxfail=1) sans re-dupliquer la couverture (la CI l’ajoute).
C. Tests a ajouter (sans sur-coder, ecrire des tests adaptatifs):
   - tests/test_health_smoke.py:
     Demarrer l’app (from app.main import app ou create_app()) et GET /health (attendre 200).
   - tests/test_common_endpoints.py:
     Tenter successivement /, /health, /docs, /openapi.json et valider qu’au moins une repond 2xx/3xx.
   - tests/test_routers_import.py:
     Import sweeping des sous-modules app.* et ciblage des packages contenant “routers” ou “routes” pour generer de la couverture de definition.
D. Workflow CI backend (.github/workflows/backend_tests.yml):
   - Conserver setup-python 3.11.
   - Ajouter actions/cache pour pip avec une cle basee sur OS + hashFiles('**/requirements*.txt').
   - Ajouter une etape “Install test deps” robuste:
     * si backend/requirements-dev.txt: pip install -r backend/requirements-dev.txt
     * sinon si backend/requirements.txt: pip install -r backend/requirements.txt && pip install pytest pytest-cov httpx pytest-xdist || true
     * sinon: pip install pytest pytest-cov httpx pytest-xdist || true
   - Etape “Run pytest”:
     working-directory: backend
     run:
       pytest -n auto --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml --junitxml=pytest-junit.xml --cov-fail-under=90
   - Artefacts:
     * Upload backend/pytest-junit.xml
     * Upload backend/coverage.xml
   - Optionnel badge:
     * Generer coverage-badge.svg a partir de coverage.xml (petit script) et uploader l’artefact.
E. Local Windows (dev quality gate, sans bloquer la CI):
   - Commandes exemple:
     cd backend
     python -m pip install -r requirements-dev.txt
     pytest --cov=app --cov-report=term-missing --cov-fail-under=90
F. Git / PR:
   - Commits proposes:
     ci(backend): cache pip and publish junit+coverage artifacts
     test(backend): add smoke tests and router import sweep to raise real coverage
     ci(backend): optional coverage badge artifact
   - Ouvrir une PR avec la ligne:
     Ref: docs/roadmap/step-08.md

ACCEPTANCE CRITERIA
- Le job backend-tests reste vert.
- Artefacts disponibles: pytest-junit.xml, coverage.xml (et coverage-badge.svg si badge active).
- Couverture reelle > 90% ou clairement montante grace aux tests smoke et import routers.
- Aucun guard existant ne regressent.
- Commands locales Windows fonctionnelles (doc minimale dans README si necessaire).

NOTES
- Ne pas baisser --cov-fail-under=90.
- Ne pas modifier d’autres jobs CI hors du backend sauf necessaire.
- Si une route n’existe pas, le test doit etre tolerant (valider qu’au moins une des routes communes repond).

Ref: docs/roadmap/step-08.md
