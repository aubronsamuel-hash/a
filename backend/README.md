# Coulisses Crew API (ETAPE 2)

Auth JWT minimale de dev (NE PAS UTILISER EN PROD telle quelle).

## Endpoints

* GET /healthz
* POST /auth/token {username,password}
* GET /auth/me (Bearer)
* GET /debug/secret (Bearer)
* POST /echo

## Flux dev rapide

1. Copier .env.example en .env et ajuster DEV_USER/DEV_PASSWORD
2. PS1\setup.ps1
3. PS1\run.ps1
4. PS1\smoke_auth.ps1 (teste token + routes protegees)
