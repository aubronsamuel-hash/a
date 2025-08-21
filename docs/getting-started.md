# Demarrage

## Prerequis

* Python 3.11+
* Git
* (Optionnel) Docker Desktop

## Installation des docs

```powershell
pip install -r requirements-docs.txt
```

## Lancer la doc en local

```powershell
# Windows
.\\scripts\\ps1\\docs\\serve.ps1
```

```bash
# Bash
./scripts/bash/docs/serve.sh
```

## Structure

```
docs/
  index.md
  getting-started.md
  backend/api.md
  ops/monitoring.md
  adr/
    0000-template.md
```

## Deploiement

* Via CI GitHub Pages (branche `gh-pages`).
* Manuel: `.\\scripts\\ps1\\docs\\gh_pages.ps1` (cree/force la branche de pages).

## Bonnes pratiques

* Pas de secrets dans la doc.
* Lier vers les READMEs specifiques.
