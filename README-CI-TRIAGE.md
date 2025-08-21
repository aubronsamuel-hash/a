# CI Triage (Windows-first)

## 1) Recuperer les runs et logs

```
$env:GITHUB_REPOSITORY="org/repo"
.\scripts\ps1\ci\fetch_runs.ps1 -Limit 20
# Choisir un RunId depuis .ci\logs\runs.txt
.\scripts\ps1\ci\fetch_job_logs.ps1 -RunId 123456789
.\scripts\ps1\ci\extract_failures.ps1
```

## 2) Repro locale (par job)

```
.\scripts\ps1\ci\repro_matrix.ps1   # genere .ci\repro_matrix.csv
.\scripts\ps1\ci\run_local.ps1 -Job backend-tests
```

## 3) Rapport

```
.\scripts\ps1\ci\report_template.ps1 -Job backend-tests -RunId 123456789 -ErrorFile ".ci\logs\123456789\run.log.errors.txt"
```

## 4) Tests

* OK: `.\\scripts\\ps1\\ci\\test_ok.ps1`
* KO: `.\\scripts\\ps1\\ci\\test_ko.ps1`

## Notes

* Requiert GitHub CLI (`gh`) pour telecharger les logs. Sinon, uploder manuellement le zip des logs dans `.ci/logs/<run>/`.
* Adapter `.ci/repro_matrix.csv` aux workflows du repo.
* Toujours coller le bloc d'erreurs Codex/CI dans la PR de fix.
