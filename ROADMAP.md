# Roadmap Officielle

## Backend & Infra (1..50)

1 - Init repo, licences, README, CODEOWNERS
2 - Bootstrap FastAPI (healthz, settings, .env)
3 - DB Users + migrations Alembic
4 - Auth JWT (login/refresh, scopes)
5 - CRUD Users (admin, pagination)
6 - CRUD Missions (multi-postes)
7 - Disponibilites (modele + endpoints)
8 - Planning semaine (endpoints agreges)
9 - Audit log global (DB + middleware)
10 - Recherche/filtrage (query params, indexes)
11 - Comptabilite missions (modeles + calculs)
12 - Validation schemas (Pydantic v2)
13 - Tests unitaires backend (pytest)
14 - Tests d integration API (httpx)
15 - Notifications email SMTP (templating)
16 - Notifications Telegram (bot)
17 - Exports CSV/PDF/ICS
18 - Rate limiting + protections basiques
19 - Caching (Redis) pour listes/filtrage
20 - Docker dev (compose)
21 - Docker prod (multi-stage, envs)
22 - CI backend (lint, tests, coverage)
23 - CI securite (bandit, pip-audit)
24 - CI image scan (trivy)
25 - Frontend scaffold (React, Tailwind, routing)
26 - UI Login + session (token storage)
27 - UI Dashboard + Missions (CRUD)
28 - UI Planning (vue semaine)
29 - UI Admin Users + Roles
30 - UI Settings (organisation, profils)
31 - Client API type (OpenAPI -> TS)
32 - Observabilite logs (JSON, request_id)
33 - Perf DB (pool, timeouts, indexes)
34 - Tests E2E UI (Playwright/Cypress)
35 - Load tests (k6: smoke, 1000 VUs)
36 - Reverse proxy (Caddy/Nginx)
37 - CORS configurable via env + middleware + tests + scripts
38 - Monitoring (Prometheus, Grafana, Alertmanager, exporters)
39 - CDN/assets + cache HTTP (etag, gzip/br)
40 - Scalabilite app (Gunicorn workers, autoscaling hints)
41 - OAuth2 (Google) en complement
42 - RBAC fin (policies par routes)
43 - Backups DB + rotation logs
44 - Taches async (RQ/Celery) pour envois lourds
45 - Multi-env (dev/staging/prod) + promotions
46 - IaC basique (Terraform/Helm selon cible)
47 - Secrets mgmt (SOPS/GHA env, rotation)
48 - Release mgmt (semver, changelog, tags)
49 - Docs produit (mkdocs) + guides ops
50 - Onboarding dev Windows-first (scripts PowerShell)

## Frontend (F1..F25)

F1 - Scaffold React + TS + Vite + Tailwind + Routing
F2 - Design system minimal (tokens, palettes, typos, dark mode opt-in)
F3 - Composants base (Button, Input, Select, Modal, Toast, Table, Badge, Tabs)
F4 - State mgmt et data fetching (React Query, caches, invalidations)
F5 - Client API type (OpenAPI -> TS, intercepteurs, mapping erreurs)
F6 - Auth front (login, refresh, storage tokens secure, role guard)
F7 - Layouts et navigation (MainShell, SideNav, TopBar, Breadcrumbs, Footer)
F8 - Page Login (formulaire, validation, erreurs, redirections)
F9 - Dashboard (KPIs missions du jour, stats, derniers evenements/audit)
F10 - Missions: liste paginee, tri/filtre, colonnes configurables, CSV export
F11 - Missions: fiche detail, creation/edition, duplication, validation formulaire
F12 - Disponibilites: vue calendrier semaine (drag-drop basique, slots)
F13 - Planning: vue equipe/semaine, affectations multi-postes, conflits visuels
F14 - Admin Utilisateurs: liste/CRUD, roles, recherche, reset mot de passe
F15 - Settings: profil, organisation, preferences (timezone, formats, dark)
F16 - Cartographie OSM/Leaflet integree dans missions (adresse -> marker)
F17 - Exports UI: declencheurs PDF/ICS/CSV via API, feedbacks et toasts
F18 - Accessibilite (a11y): focus order, ARIA, contrastes, clavier, tests axe
F19 - Performances UI: code-splitting, lazy routes, memo/virtualization tables
F20 - Gestion d erreurs: ErrorBoundary, pages 404/500, replays logs front
F21 - Internationalisation (i18n) et formats (dates/nombres) selon locale
F22 - Tests front: unitaires (vitest), composants (testing-library)
F23 - Tests E2E UI (Playwright/Cypress): parcours critiques (login, CRUD mission, planning)
F24 - Build/CI front: lint (eslint), typecheck (tsc), audit deps, preview deploy
F25 - PWA/Offline (optionnel): cache assets, placeholders, mode degrade
