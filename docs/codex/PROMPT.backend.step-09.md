# PROMPT.backend.step-09.md
SYSTEM
Tu es un agent Backend/Tests pour un monorepo FastAPI. Objectif: faire passer les tests backend (pas seulement le lint) avec une base de donnees de test ephemere et deterministe, augmenter la couverture reelle (>= 90%), et garder la CI stable.
Contraintes:
- ASCII uniquement.
- Ne pas baisser --cov-fail-under=90.
- Code Python sous backend/.
- Respecter les guards et workflows existants.
- Ne pas introduire de dependance a un service externe en CI si evitable (utiliser SQLite in-memory par defaut).

GOALS
1) Application testable:
   - Garantir que app.main expose `app` (FastAPI) OU une fabrique `create_app(settings=None)`.
   - Ajouter un drapeau Settings.TESTING = True quand lance en test.
   - Centraliser la config DB via env DATABASE_URL; fallback tests = sqlite:///:memory: (ou sqlite:///./test.db si in-memory incompatible).
2) Couche DB test:
   - Si SQLAlchemy deja present:
     * Fournir engine/session local pour les tests avec DATABASE_URL de test.
     * `Base.metadata.create_all(bind=engine)` au setup test; `drop_all` au teardown.
     * Eviter Alembic en tests (ou le rendre optionnel) pour ne pas dependre d’un service externe.
   - Si aucune couche DB n’existe: creer un squelette minimal (Base, SessionLocal) uniquement si necessaire aux tests.
3) Fixtures Pytest:
   - `settings_fixture` charge une config de test (TESTING=True, DATABASE_URL test).
   - `app_fixture` retourne l’app FastAPI (app ou create_app(settings)).
   - `client` = TestClient(app).
   - `engine` / `db_session` pour tests DB, transactionnelle avec rollback par test.
4) Tests a implementer:
   - `test_health_ok`: GET /health -> 200.
   - `test_openapi_or_docs`: au moins un de ["/", "/docs", "/openapi.json"] retourne 2xx/3xx.
   - `test_db_roundtrip`: creer table temporaire (ou utiliser un modele minimal existant), insert puis select 1 en session test -> assert OK.
   - `test_transaction_isolation`: deux tests distincts ne se voient pas (rollback entre tests).
   - `test_import_sweep`: importer modules app.* (routers/services) pour couverture structurelle.
5) CI:
   - Conserver la commande pytest avec couverture telle qu’au Step-08.
   - Installer deps de test manquantes si besoin: sqlalchemy, aiosqlite (si async sqlite), httpx, anyio, alembic (optionnel).
   - Ne pas lancer de service Postgres en CI, sauf si le repo force Postgres; sinon rester en SQLite tests.
6) Documentation rapide:
   - Ajouter un court README tests dans backend/README.md (section “Run tests locally”) avec commandes Windows/PowerShell.

ACTIONS
A. Settings - backend/app/settings.py (ou fichier existant de settings):
   - Ajouter bool TESTING (defaut False).
   - DATABASE_URL: lire os.environ, defaut "sqlite:///:memory:" en mode TESTING.
   - Fournir une fonction utilitaire get_settings().
B. App - backend/app/main.py:
   - Si app existe: s’assurer qu’il peut utiliser settings TESTING.
   - Sinon: ajouter create_app(settings=None) qui instancie FastAPI, monte routes, et retourne app.
   - Ajouter/garantir route GET /health -> {"status":"ok"}.
C. DB (SQLAlchemy) - backend/app/db.py (ou dossier):
   - Declarer Base = declarative_base().
   - engine = create_engine(DATABASE_URL, connect_args pour sqlite si necessaire).
   - SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False).
   - Fonctions utilitaires: create_all(), drop_all().
   - Si des models existent deja, ne pas dupliquer; reutiliser les imports.
D. Fixtures Pytest - backend/tests/conftest.py:
   - settings_fixture: force TESTING=True et DATABASE_URL de test.
   - engine/session fixture transactionnelle:
     * create_all() avant la session de tests; drop_all() apres.
     * Pour chaque test: demarrer transaction, bind session, rollback en teardown.
   - app_fixture: construit app (app ou create_app(settings_fixture)).
   - client fixture: TestClient(app_fixture).
E. Tests
   - backend/tests/test_health_ok.py: verifie /health -> 200.
   - backend/tests/test_common_endpoints.py: verifie qu’au moins un endpoint commun ("/", "/docs", "/openapi.json") repond 2xx/3xx.
   - backend/tests/test_db_roundtrip.py:
     - Si un modele existe (ex: User), faire un insert/select 1.
     - Sinon, creer un modele ephemere pour le test OU utiliser une table simple via SQLAlchemy Core.
   - backend/tests/test_tx_isolation.py: prouver rollback entre tests (compter les rows avant/apres).
   - backend/tests/test_import_sweep.py: walk app.* et importer modules contenant “routers”/“routes”.
F. Pytest config - backend/pytest.ini:
   [pytest]
   testpaths = tests
   addopts = -q -ra --maxfail=1
   - Ne pas remettre la couverture ici (deja dans la CI).
G. CI (rappel) - .github/workflows/backend_tests.yml:
   - Conserver working-directory: backend pour pytest.
   - S’assurer que l’etape d’installation installe sqlalchemy et httpx si absents (fallback pip install).
   - Ne pas activer un service Postgres si non utilise; SQLite suffit.
H. README - backend/README.md (section Tests):
   - Windows:
     pwsh
     cd backend
     python -m pip install -r requirements-dev.txt
     pytest --cov=app --cov-report=term-missing --cov-fail-under=90
I. GIT / PR - Commits proposes:
   feat(backend): testing settings and DB test harness (sqlite)
   test(backend): add health, common endpoints, db roundtrip and isolation tests
   ci(backend): ensure test deps installed and keep 90 coverage gate
   - PR description: ajouter la ligne
   Ref: docs/roadmap/step-09.md

ACCEPTANCE CRITERIA
- La CI backend passe les tests (pas seulement le lint).
- Couverture >= 90% ou au minimum stable et reelle (routes/DB verifiees).
- Tests deterministes: pas de dependance a un service externe, rollback entre tests.
- Aucun guard ne regressent.
- Documentation courte pour l’execution locale sous Windows.

NOTES
- Si le repo force Postgres: laisser une variante optionnelle qui spin un service postgres en CI et utilise DATABASE_URL=postgres..., sinon preferer SQLite.
- Si l’app utilise des routers dynamiques: veiller a les inclure dans create_app/app.
