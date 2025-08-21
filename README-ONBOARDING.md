# Onboarding developpeur (Windows-first)

## 1. Pre-requis

* Windows 10/11
* Python 3.11+
* Git
* (Optionnel) Docker Desktop, Node.js, MkDocs

## 2. Premiere installation

```powershell
# Verifier pre-requis
.\scripts\ps1\onboarding\check_env.ps1 -MinPython 3.11

# Copier l env dev
.\scripts\ps1\onboarding\copy_env.ps1 -Src .env.dev.example -Dst .env

# Installer deps backend
.\scripts\ps1\onboarding\setup_backend.ps1

# Demarrer l API
.\scripts\ps1\onboarding\dev_up.ps1 -Port 8000 -Reload
```

Ouvrir http://localhost:8000/healthz -> 200

## 3. Tests rapides

```powershell
.\scripts\ps1\onboarding\dev_test.ps1
```

## 4. Arret

```powershell
.\scripts\ps1\onboarding\dev_down.ps1 -Port 8000
```

## 5. E2E OK / KO

* OK: `.\scripts\ps1\onboarding\test_ok.ps1`
* KO: `.\scripts\ps1\onboarding\test_ko.ps1`
